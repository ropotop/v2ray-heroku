#! /bin/bash
set -ex
if [[ -z "${VER}" ]]; then
  VER="latest"
fi
echo ${VER}

if [[ -z "${UUID}" ]]; then
  UUID="71d6dfd1-0bfb-40a2-97e9-ff996dc83a28"
fi
echo ${UUID}

if [[ -z "${SSPASS}" ]]; then
  SSPASS="4431088"
fi
echo ${SSPASS}

rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
date -R


if [ "$VER" = "latest" ]; then
  V2RAY_URL="https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip"
else
  V_VER="v$VER"
  V2RAY_URL="https://github.com/v2fly/v2ray-core/releases/download/$V_VER/v2ray-linux-64.zip"
fi

mkdir /v2raybin
cd /v2raybin
echo ${V2RAY_URL}
wget --no-check-certificate -qO 'v2ray.zip' ${V2RAY_URL}
unzip v2ray.zip
rm -rf v2ray.zip

cat <<-EOF > /v2raybin/config.json
{
    "log":{
        "loglevel":"warning"
    },
	"inbounds": [
		{
			"port": 44330,
			"protocol": "vmess",
			"settings": {
				"clients": [
					{
						"id": "${UUID}",
						"level": 1,
						"alterId": 0
					}
				]
			},
			"streamSettings": {
				"network": "tcp"
			},
			"sniffing": {
				"enabled": true,
				"destOverride": [
					"http",
					"tls"
				]
			}
		}
		,
        {
            "protocol": "shadowsocks",
            "port": 4433,
            "settings": {
                "method": "aes-256-cfb",
                "password": "${SSPASS}",
                "network": "tcp,udp",
                "level": 1,
                "ota": false
            }
        }
		//include_socks
		//include_mtproto
		//include_in_config
		//
	],
	"outbounds": [
		{
			"protocol": "freedom",
			"settings": {
				"domainStrategy": "UseIP"
			},
			"tag": "direct"
		},
		{
			"protocol": "blackhole",
			"settings": {},
			"tag": "blocked"
        },
		{
			"protocol": "mtproto",
			"settings": {},
			"tag": "tg-out"
		}
		//include_out_config
		//
	],
	"dns": {
		"servers": [
			"https+local://cloudflare-dns.com/dns-query",
			"1.1.1.1",
			"1.0.0.1",
			"8.8.8.8",
			"8.8.4.4",
			"localhost"
		]
	},
	"routing": {
		"domainStrategy": "IPOnDemand",	
		"rules": [
			{
				"type": "field",
				"ip": [
					"0.0.0.0/8",
					"10.0.0.0/8",
					"100.64.0.0/10",
					"127.0.0.0/8",
					"169.254.0.0/16",
					"172.16.0.0/12",
					"192.0.0.0/24",
					"192.0.2.0/24",
					"192.168.0.0/16",
					"198.18.0.0/15",
					"198.51.100.0/24",
					"203.0.113.0/24",
					"::1/128",
					"fc00::/7",
					"fe80::/10"
				],
				"outboundTag": "blocked"
			},
			{
				"type": "field",
				"inboundTag": ["tg-in"],
				"outboundTag": "tg-out"
			}
			,
			{
				"type": "field",
				"domain": [
					"domain:epochtimes.com",
					"domain:epochtimes.com.tw",
					"domain:epochtimes.fr",
					"domain:epochtimes.de",
					"domain:epochtimes.jp",
					"domain:epochtimes.ru",
					"domain:epochtimes.co.il",
					"domain:epochtimes.co.kr",
					"domain:epochtimes-romania.com",
					"domain:erabaru.net",
					"domain:lagranepoca.com",
					"domain:theepochtimes.com",
					"domain:ntdtv.com",
					"domain:ntd.tv",
					"domain:ntdtv-dc.com",
					"domain:ntdtv.com.tw",
					"domain:minghui.org",
					"domain:renminbao.com",
					"domain:dafahao.com",
					"domain:dongtaiwang.com",
					"domain:falundafa.org",
					"domain:wujieliulan.com",
					"domain:ninecommentaries.com",
					"domain:shenyun.com"
				],
				"outboundTag": "blocked"
			}			,
                {
                    "type": "field",
                    "protocol": [
                        "bittorrent"
                    ],
                    "outboundTag": "blocked"
                }
			//include_ban_ad
			//include_rules
			//
		]
	},
	"transport": {
		"kcpSettings": {
            "uplinkCapacity": 100,
            "downlinkCapacity": 100,
            "congestion": true
        }
	}
}
EOF

echo /v2raybin/config.json
cat /v2raybin/config.json

cd /v2raybin
./v2ray -config config.json &
