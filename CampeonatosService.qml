pragma Singleton
import QtQuick
import Quickshell
import qs.Common

Singleton {
    id: root

    property var games: []
    property bool loading: false
    property string lastUpdated: ""

    signal gamesUpdated()

    // Copa do Brasil não está disponível no ESPN — usamos Copa Sudamericana.
    // Para trocar, substitua o url abaixo quando/se ESPN adicionar suporte.
    readonly property var endpoints: [
        {
            id: "brasileirao",
            label: "Brasileirão",
            url: "https://site.api.espn.com/apis/site/v2/sports/soccer/bra.1/scoreboard"
        },
        {
            id: "sudamericana",
            label: "Copa Sudamericana",
            url: "https://site.api.espn.com/apis/site/v2/sports/soccer/conmebol.sudamericana/scoreboard"
        },
        {
            id: "libertadores",
            label: "Libertadores",
            url: "https://site.api.espn.com/apis/site/v2/sports/soccer/conmebol.libertadores/scoreboard"
        }
    ]

    property int _pendingFetches: 0
    property var _tempGames: []

    function _dateRange() {
        const today = new Date()
        const future = new Date(today)
        future.setDate(today.getDate() + 14)
        const fmt = d => d.getFullYear().toString()
            + (d.getMonth() + 1).toString().padStart(2, "0")
            + d.getDate().toString().padStart(2, "0")
        return fmt(today) + "-" + fmt(future)
    }

    function refresh() {
        if (loading) return
        loading = true
        _tempGames = []
        _pendingFetches = endpoints.length

        const range = _dateRange()
        for (let i = 0; i < endpoints.length; i++) {
            _fetchEndpoint(endpoints[i], range)
        }
    }

    function _fetchEndpoint(ep, range) {
        const url = ep.url + "?dates=" + range
        Proc.runCommand(
            "campeonatos_" + ep.id,
            ["curl", "-sS", "--compressed", "--connect-timeout", "8", "--max-time", "15", url],
            function(output, exitCode) {
                _handleResponse(ep, output, exitCode)
            },
            0
        )
    }

    function _handleResponse(ep, output, exitCode) {
        if (exitCode === 0) {
            const raw = output.trim()
            if (raw && raw[0] === "{") {
                try {
                    const data = JSON.parse(raw)
                    const events = data.events || []
                    events.forEach(ev => {
                        const state = ev.status?.type?.state
                        if (state === "pre" || state === "in") {
                            const comps = ev.competitions?.[0]?.competitors || []
                            const home = comps.find(c => c.homeAway === "home")?.team?.shortDisplayName
                                || comps.find(c => c.homeAway === "home")?.team?.displayName
                                || "?"
                            const away = comps.find(c => c.homeAway === "away")?.team?.shortDisplayName
                                || comps.find(c => c.homeAway === "away")?.team?.displayName
                                || "?"
                            const gameDate = new Date(ev.date)
                            _tempGames = _tempGames.concat([{
                                championship: ep.label,
                                championshipId: ep.id,
                                home: home,
                                away: away,
                                dateMs: gameDate.getTime(),
                                live: state === "in",
                                statusDetail: ev.status?.type?.shortDetail || ""
                            }])
                        }
                    })
                } catch(e) {
                    console.error("campeonatos: parse error for", ep.id, ":", e)
                }
            }
        } else {
            console.warn("campeonatos: fetch failed for", ep.id, "exit code:", exitCode)
        }

        _pendingFetches--
        if (_pendingFetches === 0) {
            games = _tempGames.slice().sort((a, b) => a.dateMs - b.dateMs)
            loading = false
            lastUpdated = Qt.formatTime(new Date(), "HH:mm")
            gamesUpdated()
        }
    }

    Timer {
        interval: 1800000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
