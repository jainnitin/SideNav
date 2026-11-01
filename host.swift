import Cocoa
import SafariServices

let repo = "jainnitin/SideNav"
let extID = "com.nitinjain.sidenav.Extension"
let current = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"

// Looks up the latest release tag on GitHub. Sends nothing about the user or machine.
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
                  tag.trimmingCharacters(in: CharacterSet(charactersIn: "v")).compare(current, options: .numeric) == .orderedDescending
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
