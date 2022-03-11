
# Speedtest exporter

A prometheus exporter that exposes speedtest metrics


## ookla speedtest data example

```json
{
    "download": {
        "bandwidth": 399067,
        "bytes": 5384016,
        "elapsed": 13606
    },
    "interface": {
        "externalIp": "XX.XX.XX.XX",
        "internalIp": "172.XX.XX.XX",
        "isVpn": false,
        "macAddr": "00:00:00:00:00:00",
        "name": "eth0"
    },
    "isp": "ISP",
    "packetLoss": 0,
    "ping": {
        "jitter": 4.645,
        "latency": 200.861
    },
    "result": {
        "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
        "url": "https://www.speedtest.net/result/c/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    },
    "server": {
        "country": "Country",
        "host": "speedtest.domain.com",
        "id": 12345,
        "ip": "X.X.X.X",
        "location": "Somewhere",
        "name": "Somename",
        "port": 8080
    },
    "timestamp": "XX-XX-XXTXX:XX:XXZ",
    "type": "result",
    "upload": {
        "bandwidth": 63378,
        "bytes": 503048,
        "elapsed": 9023
    }
}

```
