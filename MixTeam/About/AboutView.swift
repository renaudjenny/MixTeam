import SwiftUI

struct AboutView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            HStack { Spacer() }
            if verticalSizeClass == .regular {
                closeCapsule
            } else {
                HStack {
                    Spacer()
                    Button(action: close) {
                        Text("Done")
                    }.padding()
                }
            }
            VStack {
                Image(uiImage: #imageLiteral(resourceName: "Logo"))
                    .cornerRadius(16)
                    .padding()
                    .padding(.top)
                    .shadow(radius: 5)
                VStack(spacing: 32) {
                    developmentCredit
                    openSourceCredit
                    iconsAndIllustrationsCredit
                    Text("Thank you for your support!")
                        .multilineTextAlignment(.center)
                        .font(.headline)
                    rateThisApp
                }
                .padding()
            }
            .background(colorScheme == .light
                ? Color.gray.opacity(1/2)
                : Color.black.opacity(3/4)
            )
            .modifier(AddDashedCardStyle())
        }
    }

    private var developmentCredit: some View {
        VStack {
            Text("This application has been made by\nRenaud Jenny")
                .multilineTextAlignment(.center)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            WebLink(text: "@Renox0", url: .renox0Twitter)
        }
    }

    private var openSourceCredit: some View {
        VStack {
            Text("Based on open source projects you can find on my GitHub")
                .multilineTextAlignment(.center)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            WebLink(text: "https://github.com/renaudjenny", url: .renaudjennyGithub)
        }
    }

    private var iconsAndIllustrationsCredit: some View {
        VStack {
            Text("Icons and illustrations by\nMathilde Seyller")
                .multilineTextAlignment(.center)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
            WebLink(text: "@MathildeSeyller", url: .myobrielInstagram)
        }
    }

    private var rateThisApp: some View {
        WebLink(text: "Rate this application on the App Store", url: .appStoreWriteReview)
            .multilineTextAlignment(.center)
    }

    private func close() {
        presentationMode.wrappedValue.dismiss()
    }

    private var closeCapsule: some View {
        Capsule(style: .circular)
            .fill(
                colorScheme == .light
                    ? Color.black.opacity(1/4)
                    : Color.white.opacity(1/4)
            )
            .frame(width: 50, height: 5)
    }
}

struct WebLink: View {
    let text: String
    let url: URL

    var body: some View {
        Button(action: openURL) {
            Text(text)
        }
    }

    private func openURL() {
        UIApplication.shared.open(url)
    }
}

private extension URL {
    static var renox0Twitter: Self {
        guard let url = Self(string: "https://twitter.com/Renox0") else {
            fatalError("Cannot build the Twitter URL")
        }
        return url
    }

    static var renaudjennyGithub: Self {
        guard let url = Self(string: "https://github.com/renaudjenny") else {
            fatalError("Cannot build the Github URL")
        }
        return url
    }

    static var myobrielInstagram: Self {
        guard let url = Self(string: "https://www.instagram.com/myobriel") else {
            fatalError("Cannot build the instagram URL")
        }
        return url
    }

    static var appStoreWriteReview: Self {
        guard let url = Self(string: "itms-apps://itunes.apple.com/app/id1526493495?action=write-review") else {
            fatalError("Cannot build the AppStore URL")
        }
        return url
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutView().environment(\.verticalSizeClass, .regular)
            AboutView()
                .previewLayout(.fixed(width: 568, height: 320))
                .environment(\.verticalSizeClass, .compact)
        }
    }
}
