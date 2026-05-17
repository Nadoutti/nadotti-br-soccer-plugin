import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "campeonatos"

    StyledText {
        width: parent.width
        text: "Campeonatos BR"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configura quais campeonatos aparecem na bar e no painel"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: champsColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: champsColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Campeonatos"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            ToggleSetting {
                settingKey: "showBrasileirao"
                label: "Brasileirão Série A"
                defaultValue: true
            }

            ToggleSetting {
                settingKey: "showSudamericana"
                label: "Copa Sudamericana"
                defaultValue: true
            }

            ToggleSetting {
                settingKey: "showLibertadores"
                label: "Libertadores"
                defaultValue: true
            }
        }
    }

    SliderSetting {
        settingKey: "maxGamesPerChamp"
        label: "Jogos por campeonato"
        description: "Número máximo de jogos exibidos por campeonato no painel"
        minimum: 2
        maximum: 8
        defaultValue: 5
        unit: " jogos"
    }
}
