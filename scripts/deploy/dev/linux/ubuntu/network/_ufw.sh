#!/bin/bash

#set -euo pipefail
# ======================================================================================================================
# Scripts - Deploy - Dev - Linux - Ubuntu - Network
# ======================================================================================================================
# >>>> Platform
if [ "${PLATFORM_TYPE}" == "Linux" ]; then
    # ------------------------------------------------------------------------------------------------------------------
    # Platform - Linux - Ubuntu
    # ------------------------------------------------------------------------------------------------------------------
    # >>>> Environment
    if [ "${ENVIRONMENT_NAME}" == "dev" ]; then

      echo ">>>> Linux - Network - UFW"
      echo

      # ----------------------------------------------------------------------------------------------------------------
      # Packages
      # ----------------------------------------------------------------------------------------------------------------

      local addPackageList="ufw"
      for pkgItem in ${addPackageList}; do
        local APT_PKG_INFO
        APT_PKG_INFO=$(dpkg -l | grep -i "${pkgItem}" | awk '{print $2}' | cut -d ':' -f1 | awk "/^${pkgItem}$/")
        if [ "${APT_PKG_INFO}" != "${pkgItem}" ]; then
          sudo apt install -y "${pkgItem}"
          sudo systemctl enable "${pkgItem}"
          sudo systemctl start "${pkgItem}"
          echo
        fi
      done

      # ----------------------------------------------------------------------------------------------------------------
      # Configuration
      # ----------------------------------------------------------------------------------------------------------------

      local UFW_STATUS
      UFW_STATUS=$(sudo ufw status | grep "Status" | awk '{print $2}')

      if [ "${UFW_STATUS}" != "active" ]; then

        # >>>> Remove package
        sudo ufw --force disable
        sudo apt-get purge ufw -y
        sudo apt-get autoremove -y
        sudo apt-get update -y
        sudo apt-get install ufw -y

        # >>>> Reset current rules
        sudo ufw --force reset
        echo

        # >>>> Enable logging
        sudo ufw logging off
        echo

        # --------------------------------------------------------------------------------------------------------------
        # UFW - default
        # --------------------------------------------------------------------------------------------------------------

        # >>>> Default
        sudo sed -i 's/^IPV6=yes/IPV6=no/' /etc/default/ufw
        sudo sed -i 's/^DEFAULT_FORWARD_POLICY="ACCEPT"/DEFAULT_FORWARD_POLICY="DROP"/' /etc/default/ufw

        # >>>> Incoming
        sudo ufw default deny incoming

        # >>>> Outgoing
        sudo ufw default allow outgoing

        # --------------------------------------------------------------------------------------------------------------
        # UFW - network
        # --------------------------------------------------------------------------------------------------------------

        # >>>> Private Network - Personal
        #sudo ufw deny from 10.0.0.0/8
        #sudo ufw deny from 192.168.0.0/16

        # >>>> Private Network - Office


        # >>>> Private Network - Multicast
        sudo ufw deny from any to 239.255.255.250             # Multicast

        # --------------------------------------------------------------------------------------------------------------
        # UFW - service - Allow
        # --------------------------------------------------------------------------------------------------------------

        sudo ufw allow domain comment "DNS"                   # DNS
        sudo ufw allow ntp comment 'NTP'                      # NTP

        # --------------------------------------------------------------------------------------------------------------
        # UFW - service - Deny
        # --------------------------------------------------------------------------------------------------------------

        sudo ufw deny from any to any port 1                  # TCP Port Service Multiplexer (TCPMUX) - 비정상 트래픽 스캔 대상
        sudo ufw deny from any to any port 7                  # Echo - DoS 공격(Echo-Chargen)에 악용 가능
        sudo ufw deny from any to any port 9                  # Discard - 자원 소모 공격 타겟
        sudo ufw deny from any to any port 13                 # Daytime - 시스템 시간 및 정보 유출 방지
        sudo ufw deny from any to any port 17                 # Quote of the Day (QOTD) - 취약한 고전 서비스
        sudo ufw deny from any to any port 19                 # Character Generator (Chargen) - DDoS 증폭 공격에 자주 이용됨
        sudo ufw deny from any to any port 20                 # FTP (Data) - 암호화되지 않은 파일 전송(데이터 채널)
        sudo ufw deny from any to any port 21                 # FTP (Control) - 암호화되지 않은 로그인 정보 노출 위험
        sudo ufw deny from any to any port 22                 # SSH - 원격 접속 (특정 IP만 허용하는 화이트리스트 방식 권장)
        sudo ufw deny from any to any port 23                 # Telnet - 암호화되지 않은 원격 접속 (절대 금지)
        sudo ufw deny from any to any port 24                 # Private Mail System - 사용되지 않는 사설 메일 포트
        sudo ufw deny from any to any port 69                 # TFTP (Trivial FTP) - 인증 없는 간이 파일 전송 프로토콜
        sudo ufw deny from any to any port 70                 # Gopher - 아주 오래된 정보 검색 서비스
        sudo ufw deny from any to any port 111                # RPCbind - 네트워크 서비스 정보 및 취약점 노출 위험
        sudo ufw deny from any to any port 135                # NetBIOS (RPC Endpoint Mapper) - 윈도우 기반 원격 취약점 노출
        sudo ufw deny from any to any port 137                # NetBIOS (Name Service) - 내부 네트워크 이름 정보 유출
        sudo ufw deny from any to any port 138                # NetBIOS (Datagram Service) - 파일 공유 관련 취약점
        sudo ufw deny from any to any port 139                # NetBIOS (Session Service) - 윈도우 시스템 정보 노출 위험
        sudo ufw deny from any to any port 161                # SNMP (Simple Network Management Protocol) - 장비 모니터링 정보 유출
        sudo ufw deny from any to any port 162                # SNMP Trap - 관리 장비로의 비정상 트래픽 전송 차단
        sudo ufw deny from any to any port 445                # Microsoft-DS (SMB) - 랜섬웨어(WannaCry 등) 전파 핵심 포트
        sudo ufw deny from any to any port 514                # Syslog - 외부로 로그가 유출되어 시스템 구조 노출 방지
        sudo ufw deny from any to any port 515                # LPD (Line Printer Daemon) - 인쇄 서비스 취약점 방어
        sudo ufw deny from any to any port 540                # UUCP (Unix-to-Unix Copy) - 고전적인 유닉스 간 파일 복사
        sudo ufw deny from any to any port 542                # Commerce Applications - 오래된 상거래 프로토콜
        sudo ufw deny from any to any port 591                # FileMaker Web Publishing - 특정 데이터베이스 웹 서비스 노출 차단
        sudo ufw deny from any to any port 636                # LDAPS (LDAP over SSL) - 디렉토리 서비스 정보 유출 방지
        sudo ufw deny from any to any port 873                # Rsync - 인증되지 않은 사용자의 파일 시스템 동기화 방지
        sudo ufw deny from any to any port 981                # Checkpoint Firewall GUI - 관리 인터페이스 외부 노출 차단
        sudo ufw deny from any to any port 990                # FTPS (Implicit) - 암호화된 FTP 제어 신호
        sudo ufw deny from any to any port 992                # Telnet over SSL - 암호화된 텔넷 (현대 보안 미충족)
        sudo ufw deny from any to any port 1080               # SOCKS Proxy - 익명 프록시로 악용되는 것을 방지
        sudo ufw deny from any to any port 1900               # SSDP (UPnP) - 로컬 장치 검색 프로토콜, DDoS 증폭 공격 타겟
        sudo ufw deny from any to any port 2082               # cPanel - 호스팅 관리 패널 (HTTP)
        sudo ufw deny from any to any port 2083               # cPanel - 호스팅 관리 패널 (HTTPS)
        sudo ufw deny from any to any port 2086               # WHM - 웹 호스트 관리자 (HTTP)
        sudo ufw deny from any to any port 2087               # WHM - 웹 호스트 관리자 (HTTPS)
        sudo ufw deny from any to any port 3128               # Squid Proxy - 프록시 서버 악용 방지
        sudo ufw deny from any to any port 3690               # SVN (Subversion) - 소스 코드 관리 시스템 포트 노출 차단
        sudo ufw deny from any to any port 4369               # Erlang Port Mapper Daemon (EPMD) - RabbitMQ 등 관련 노드 정보 노출
        sudo ufw deny from any to any port 5228               # Google Play Services - 서버 환경에서 불필요한 구글 서비스 통신 차단
        sudo ufw deny from any to any port 5551               # OpenTofu/Terraform/Dev tools 관련 - 불필요한 관리 서비스 노출 방지
        sudo ufw deny from any to any port 5552               # 기타 개발 툴용 포트 스캔 방어
        sudo ufw deny from any to any port 5985               # WinRM (HTTP) - 윈도우 원격 관리 프로토콜
        sudo ufw deny from any to any port 5986               # WinRM (HTTPS) - 윈도우 원격 관리 프로토콜
        sudo ufw deny from any to any port 17500              # Dropbox LanSync - 서버 내 불필요한 개인용 동기화 서비스 차단

        # --------------------------------------------------------------------------------------------------------------
        # UFW - tools
        # --------------------------------------------------------------------------------------------------------------

        # >>>> Update allowed ports for App      - PHP
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 9001 proto tcp comment 'PHP - Xdebug - DBGp Proxy'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 9003 proto tcp comment 'PHP - Xdebug'

        # >>>> Update allowed ports for App      - Symfony Local Server
        sudo ufw allow 8000/tcp comment 'Symfony Local server - App 0'
        sudo ufw allow 8081/tcp comment 'Symfony Local server - App 1'
        sudo ufw allow 8082/tcp comment 'Symfony Local server - App 2'

        # >>>> Update allowed ports for Cache    - Redis
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 6379 proto tcp comment 'Redis'

        # >>>> Update allowed ports for Database - PostgreSQL
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5432 proto tcp comment 'PostgreSQL'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5433 proto tcp comment 'PostgreSQL - pgAdmin'

        # >>>> Update allowed ports for Message  - RabbitMQ
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 4369  proto tcp comment 'RabbitMQ'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5671  proto tcp comment 'RabbitMQ'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5672  proto tcp comment 'RabbitMQ'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5552  proto tcp comment 'RabbitMQ - stream'

        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 15672 proto tcp comment 'RabbitMQ - http'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 15691 proto tcp comment 'RabbitMQ - http'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 15692 proto tcp comment 'RabbitMQ - http'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 25672 proto tcp comment 'RabbitMQ - clustering'

        # >>>> Update allowed ports for Server   - Nginx
        sudo ufw allow http  comment 'Nginx - HTTP'
        sudo ufw allow https comment 'Nginx - HTTPS'

        # >>>> Update allowed ports for Tools    - Docker
        sudo ufw allow from 172.17.0.0/16

        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 1025 comment 'Mailer  - SMTP'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 1080 comment 'Mailer  - Website'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 5050 comment 'pgAdmin - WebApp'
        sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 8080 comment 'Docker  - WebApp'

        # --------------------------------------------------------------------------------------------------------------
        # Update
        # --------------------------------------------------------------------------------------------------------------

        sudo ufw disable
        echo

        sudo ufw enable
        echo

        sudo systemctl restart NetworkManager
      fi

      # ----------------------------------------------------------------------------------------------------------------
      # UFW - Status
      # ----------------------------------------------------------------------------------------------------------------

      sudo ufw status verbose
      echo

    fi
fi
