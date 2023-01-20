//
//  AcknowledgmentView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-20.
//

import SwiftUI

struct Project {
    var name: String
    var url: URL
}

struct AcknowledgmentView: View {
    let projects = [
        Project(name: "SwiftOTP", url: URL(string: "https://github.com/lachlanbell/SwiftOTP")!),
        Project(name: "CodeScanner", url: URL(string: "https://github.com/twostraws/CodeScanner")!)
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
                HStack {
                    Link("Hacking With Swift", destination: URL(string: "https://www.hackingwithswift.com/")!)
                    Spacer()
                    Image(systemName: "link")
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
