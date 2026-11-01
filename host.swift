import Cocoa
import SafariServices

let repo = "jainnitin/SideNav"
let extID = "com.nitinjain.sidenav.Extension"
let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"

func isNewer(_ a: String, than b: String) -> Bool {
    let x = a.split(separator: ".").map { Int($0) ?? 0 }
    let y = b.split(separator: ".").map { Int($0) ?? 0 }
    for i in 0..<max(x.count, y.count) {
        let p = i < x.count ? x[i] : 0, q = i < y.count ? y[i] : 0
        if p != q { return p > q }
    }
    return false
}

// Asks GitHub for the latest release tag; sends nothing about the user or machine.
func checkForUpdate(done: @escaping () -> Void) {
    guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else { return done() }
    var req = URLRequest(url: url, timeoutInterval: 5)
    req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
    URLSession(configuration: .ephemeral).dataTask(with: req) { data, _, _ in
        DispatchQueue.main.async {
            defer { done() }
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tag = json["tag_name"] as? String,
                  let page = (json["html_url"] as? String).flatMap(URL.init(string:)),
                  page.scheme == "https", page.host == "github.com",
                  page.path.hasPrefix("/\(repo)/"),
                  isNewer(tag.trimmingCharacters(in: CharacterSet(charactersIn: "vV")), than: current)
            else { return }
            NSApp.activate(ignoringOtherApps: true)
            let alert = NSAlert()
            alert.messageText = "SideNav \(tag) is available"
            alert.informativeText = "You have \(current). Download the new version, drag it to Applications, and replace the old one."
            alert.addButton(withTitle: "Download")
            alert.addButton(withTitle: "Later")
            if alert.runModal() == .alertFirstButtonReturn { NSWorkspace.shared.open(page) }
        }
    }.resume()
}

func showExtensionSettings() {
    SFSafariApplication.showPreferencesForExtension(withIdentifier: extID) { _ in
        DispatchQueue.main.async { NSApp.terminate(nil) }
    }
}

NSApplication.shared.setActivationPolicy(.accessory)
checkForUpdate(done: showExtensionSettings)
NSApplication.shared.run()
