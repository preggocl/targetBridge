import SwiftUI

struct TBDisplaySenderAboutView: View {
    @ObservedObject var service: TBDisplaySenderService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SurfaceCard {
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.30),
                                        Color.cyan.opacity(0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Image(systemName: "display.2")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    .frame(width: 74, height: 74)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(TBDisplaySenderL10n.appName(service.language))
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                        Text(aboutSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        versionChip
                    }

                    Spacer()

                    Button(closeTitle) {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }

            SurfaceCard {
                VStack(alignment: .leading, spacing: 14) {
                    sectionHeading(projectTitle)
                    Text(projectDescription)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 12) {
                        Link(destination: URL(string: "https://github.com/swellweb/targetBridge")!) {
                            Label(githubTitle, systemImage: "link")
                        }
                        .buttonStyle(.borderedProminent)

                        Link(destination: URL(string: "https://github.com/swellweb/targetBridge/releases/latest")!) {
                            Label(releaseTitle, systemImage: "shippingbox")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            SurfaceCard {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeading(creditsTitle)
                    Text(creditsBody)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .frame(minWidth: 620, minHeight: 420)
        .background(appBackground)
        // Fixed dark background → force dark scheme so semantic text colors stay
        // light and don't render dark-on-dark in system Light mode.
        .preferredColorScheme(.dark)
    }

    private var versionChip: some View {
        Text("\(versionTitle) \(TBDisplaySenderBuildInfo.versionDisplay)")
            .font(.system(.footnote, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(.caption, design: .rounded, weight: .bold))
            .tracking(1.0)
            .foregroundStyle(.secondary)
    }

    private var appBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.13, blue: 0.14),
                Color(red: 0.08, green: 0.09, blue: 0.10)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var aboutSubtitle: String {
        switch service.language {
        case .italian: return "Target Display Mode via una pipeline diretta Mac-to-Mac per sender Intel e display iMac 4K/5K."
        case .english: return "Target Display Mode through a direct Mac-to-Mac pipeline for Intel senders and 4K/5K iMac displays."
        case .german: return "Target Display Mode über eine direkte Mac-zu-Mac-Pipeline für Intel-Sender und 4K/5K-iMac-Displays."
        case .french: return "Target Display Mode via une chaîne Mac à Mac directe pour sender Intel et écrans iMac 4K/5K."
        case .chinese: return "通过直接的 Mac 到 Mac 管线，让 Intel 发送端连接 4K/5K iMac 显示器。"
        }
    }

    private var projectTitle: String {
        switch service.language {
        case .italian: return "Progetto"
        case .english: return "Project"
        case .german: return "Projekt"
        case .french: return "Projet"
        case .chinese: return "项目"
        }
    }

    private var projectDescription: String {
        switch service.language {
        case .italian: return "TargetBridge cattura il desktop o il monitor virtuale sul Mac sender, codifica lo stream e lo presenta su un iMac receiver via Thunderbolt Bridge o Network Link sperimentale."
        case .english: return "TargetBridge captures the sender desktop or virtual display, encodes the stream, and presents it on an iMac receiver over Thunderbolt Bridge or experimental Network Link."
        case .german: return "TargetBridge erfasst den Sender-Desktop oder das virtuelle Display, kodiert den Stream und zeigt ihn auf einem iMac-Empfänger über Thunderbolt Bridge oder experimentellen Network Link an."
        case .french: return "TargetBridge capture le bureau ou l’écran virtuel du sender, encode le flux et l’affiche sur un iMac receiver via Thunderbolt Bridge ou Network Link expérimental."
        case .chinese: return "TargetBridge 会捕获发送端 Mac 的桌面或虚拟显示器，对流进行编码，并通过 Thunderbolt Bridge 或实验性的 Network Link 在 iMac 接收端上显示。"
        }
    }

    private var creditsTitle: String {
        switch service.language {
        case .italian: return "Crediti"
        case .english: return "Credits"
        case .german: return "Mitwirkende"
        case .french: return "Crédits"
        case .chinese: return "致谢"
        }
    }

    private var creditsBody: String {
        switch service.language {
        case .italian: return "TargetBridge originale creato da swellweb e dalla community open source. Fork TargetBridge Intel Sender sviluppato da AndyStuardo. Contributi chiave da ThomasWaldmann, DrDavidL, potar712 e altri membri della community. Licenza MIT; restano conservati copyright e attribuzione originali."
        case .english: return "Original TargetBridge created by swellweb and its open-source community. TargetBridge Intel Sender fork developed by AndyStuardo. Key contributions from ThomasWaldmann, DrDavidL, potar712, and other community members. MIT licensed; original copyright and attribution are preserved."
        case .german: return "Das ursprüngliche TargetBridge wurde von swellweb und der Open-Source-Community erstellt. TargetBridge Intel Sender Fork entwickelt von AndyStuardo. Beiträge von ThomasWaldmann, DrDavidL, potar712 und weiteren Mitgliedern. MIT-Lizenz; ursprüngliches Copyright und Namensnennung bleiben erhalten."
        case .french: return "TargetBridge original créé par swellweb et sa communauté open source. Fork TargetBridge Intel Sender développé par AndyStuardo. Contributions de ThomasWaldmann, DrDavidL, potar712 et d’autres membres. Licence MIT ; copyright et attribution d’origine conservés."
        case .chinese: return "原版 TargetBridge 由 swellweb 和开源社区创建。TargetBridge Intel Sender 分支由 AndyStuardo 开发。ThomasWaldmann、DrDavidL、potar712 等社区成员亦有贡献。采用 MIT 许可证，并保留原始版权和署名。"
        }
    }

    private var githubTitle: String {
        switch service.language {
        case .italian: return "GitHub"
        case .english: return "GitHub"
        case .german: return "GitHub"
        case .french: return "GitHub"
        case .chinese: return "GitHub"
        }
    }

    private var releaseTitle: String {
        switch service.language {
        case .italian: return "Ultima release"
        case .english: return "Latest release"
        case .german: return "Letztes Release"
        case .french: return "Dernière version"
        case .chinese: return "最新发布"
        }
    }

    private var versionTitle: String {
        switch service.language {
        case .italian: return "Versione"
        case .english: return "Version"
        case .german: return "Version"
        case .french: return "Version"
        case .chinese: return "版本"
        }
    }

    private var closeTitle: String {
        switch service.language {
        case .italian: return "Chiudi"
        case .english: return "Close"
        case .german: return "Schließen"
        case .french: return "Fermer"
        case .chinese: return "关闭"
        }
    }
}
