//
//  QRScannerViewController.swift
//  app
//
//  Created by Денис Ефименков on 29.09.2025.
//

import UIKit
import AVFoundation
import SnapKit

final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onCode: ((String) -> Void)?
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let closeButton = UIButton(type: .system)
    private let sessionQueue = DispatchQueue(label: "qr.session")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupClose()
    }

    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                DispatchQueue.main.async { self.showFail("Камера недоступна") }
                return
            }
            self.session.beginConfiguration()
            self.session.addInput(input)

            let output = AVCaptureMetadataOutput()
            guard self.session.canAddOutput(output) else {
                self.session.commitConfiguration()
                DispatchQueue.main.async { self.showFail("Ошибка инициализации камеры") }
                return
            }
            self.session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: .main)
            output.metadataObjectTypes = [.qr, .aztec, .pdf417, .dataMatrix, .code128]
            self.session.commitConfiguration()

            DispatchQueue.main.async {
                let layer = AVCaptureVideoPreviewLayer(session: self.session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.view.bounds
                self.view.layer.addSublayer(layer)
                self.previewLayer = layer
            }
            self.session.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupClose() {
        if #available(iOS 15, *) {
            var cfg = UIButton.Configuration.plain()
            cfg.title = "Закрыть"; cfg.baseForegroundColor = .white
            closeButton.configuration = cfg
        } else {
            closeButton.setTitle("Закрыть", for: .normal)
            closeButton.setTitleColor(.white, for: .normal)
        }
        closeButton.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.right.equalToSuperview().inset(16)
        }
    }

    @objc private func onClose() {
        sessionQueue.async { [weak self] in self?.session.stopRunning() }
        dismiss(animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let str = obj.stringValue else { return }
        sessionQueue.async { [weak self] in self?.session.stopRunning() }
        dismiss(animated: true) { [weak self] in self?.onCode?(str) }
    }

    private func showFail(_ msg: String) {
        let a = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default) { _ in self.dismiss(animated: true) })
        present(a, animated: true)
    }
}


