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
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let closeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
        setupClose()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            showFail("Камера недоступна")
            return
        }
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            showFail("Ошибка инициализации камеры")
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr, .aztec, .pdf417, .dataMatrix, .code128]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    
    private func setupClose() {
        if #available(iOS 15, *) {
            var cfg = UIButton.Configuration.plain()
            cfg.title = "Закрыть"
            cfg.baseForegroundColor = .white
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
        session.stopRunning()
        dismiss(animated: true)
    }
    
    private func showFail(_ msg: String) {
        let a = UIAlertController(title: "Ошибка", message: msg, preferredStyle: .alert)
        a.addAction(.init(title: "OK", style: .default) { _ in self.dismiss(animated: true) })
        present(a, animated: true)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let str = obj.stringValue else { return }
        session.stopRunning()
        dismiss(animated: true) { [weak self] in self?.onCode?(str) }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
}

