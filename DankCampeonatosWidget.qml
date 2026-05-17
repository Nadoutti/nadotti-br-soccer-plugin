import QtQuick
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property var champOrder: ["brasileirao", "sudamericana", "libertadores"]
    readonly property var champLabels: ({
        "brasileirao": "Brasileirão",
        "sudamericana": "Copa Sudamericana",
        "libertadores": "Libertadores"
    })

    property var nextGame: {
        const live = CampeonatosService.games.find(g => g.live)
        if (live) return live
        return CampeonatosService.games[0] || null
    }

    property string barText: {
        if (CampeonatosService.loading) return "..."
        if (!nextGame) return "Sem jogos"
        const h = nextGame.home.substring(0, 4).toUpperCase()
        const a = nextGame.away.substring(0, 4).toUpperCase()
        if (nextGame.live) return h + " x " + a + " • AO VIVO"
        const d = new Date(nextGame.dateMs)
        const hh = d.getHours().toString().padStart(2, "0")
        const mm = d.getMinutes().toString().padStart(2, "0")
        return h + " x " + a + " " + hh + ":" + mm
    }

    function formatGameDate(dateMs) {
        const d = new Date(dateMs)
        const day = d.getDate().toString().padStart(2, "0")
        const mon = (d.getMonth() + 1).toString().padStart(2, "0")
        const hh = d.getHours().toString().padStart(2, "0")
        const mm = d.getMinutes().toString().padStart(2, "0")
        return day + "/" + mon + " " + hh + ":" + mm
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "sports_soccer"
                size: Theme.iconSize - 6
                color: root.nextGame?.live ? Theme.primary : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.barText
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: root.nextGame?.live ? Theme.primary : Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: 2

            DankIcon {
                name: "sports_soccer"
                size: Theme.iconSize - 6
                color: root.nextGame?.live ? Theme.primary : Theme.surfaceVariantText
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            headerText: "Campeonatos BR"
            detailsText: CampeonatosService.loading
                ? "Carregando..."
                : (CampeonatosService.games.length === 0
                    ? "Nenhum jogo próximo"
                    : ("Atualizado às " + CampeonatosService.lastUpdated))
            showCloseButton: true

            headerActions: Component {
                DankActionButton {
                    iconName: "refresh"
                    tooltipText: "Atualizar"
                    onClicked: CampeonatosService.refresh()
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingM
                topPadding: Theme.spacingS
                bottomPadding: Theme.spacingS

                Repeater {
                    model: root.champOrder
                    delegate: Column {
                        id: champCol
                        width: parent.width
                        spacing: Theme.spacingXS

                        readonly property string champId: modelData
                        readonly property var chGames: {
                            const id = champId
                            return CampeonatosService.games.filter(g => g.championshipId === id).slice(0, 5)
                        }

                        visible: chGames.length > 0

                        Row {
                            width: parent.width
                            spacing: Theme.spacingXS

                            DankIcon {
                                name: "sports_soccer"
                                size: 14
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: root.champLabels[champCol.champId] || champCol.champId
                                font.pixelSize: Theme.fontSizeMedium
                                font.weight: Font.Bold
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        Repeater {
                            model: champCol.chGames
                            delegate: StyledRect {
                                id: gameCard
                                width: parent.width
                                height: gameRow.implicitHeight + Theme.spacingS * 2
                                color: modelData.live
                                    ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                    : Theme.surfaceContainerHigh
                                radius: Appearance.rounding.small

                                Row {
                                    id: gameRow
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        verticalCenter: parent.verticalCenter
                                        leftMargin: Theme.spacingS
                                        rightMargin: Theme.spacingS
                                    }
                                    spacing: Theme.spacingS

                                    DankIcon {
                                        name: modelData.live ? "radio_button_checked" : "schedule"
                                        size: 14
                                        color: modelData.live ? Theme.primary : Theme.surfaceVariantText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    StyledText {
                                        text: modelData.home + " x " + modelData.away
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceText
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.width - dateLabel.width - 14 - Theme.spacingS * 2
                                    }

                                    StyledText {
                                        id: dateLabel
                                        text: modelData.live
                                            ? (modelData.statusDetail || "AO VIVO")
                                            : root.formatGameDate(modelData.dateMs)
                                        font.pixelSize: Theme.fontSizeSmall
                                        font.weight: modelData.live ? Font.Bold : Font.Normal
                                        color: modelData.live ? Theme.primary : Theme.surfaceVariantText
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
