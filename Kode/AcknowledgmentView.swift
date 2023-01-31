//
//  AcknowledgmentView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-20.
//

import SwiftUI

struct NamedURL {
    var name: String
    var url: URL
}

struct AcknowledgmentView: View {
    let projects = [
        NamedURL(name: "SwiftOTP", url: URL(string: "https://github.com/lachlanbell/SwiftOTP")!),
        NamedURL(name: "CodeScanner", url: URL(string: "https://github.com/twostraws/CodeScanner")!)
    ]
    
    let guides = [
        NamedURL(name: "Hacking With Swift", url: URL(string: "https://www.hackingwithswift.com")!),
        NamedURL(name: "Kodeco", url: URL(string: "https://www.kodeco.com/books/watchos-with-swiftui-by-tutorials")!)
    ]

    var body: some View {
        List {
            Section(header: Text("Dependencies")) {
                ForEach(projects, id: \.name) { project in
                    HStack {
                        Link("\(project.name)", destination: project.url)
                        Spacer()
                        Image(systemName: "link")
                    }
                }
            }
            
            Section(header: Text("Guides")) {
                ForEach(guides, id: \.name) { guide in
                    HStack {
                        Link("\(guide.name)", destination: guide.url)
                        Spacer()
                        Image(systemName: "link")
                    }
                }
            }
        }
    }
}

struct AcknowledgmentView_Previews: PreviewProvider {
    static var previews: some View {
        AcknowledgmentView()
    }
}
