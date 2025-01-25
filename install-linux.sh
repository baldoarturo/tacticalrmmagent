#!/bin/bash
echo $1
if [[ $# -eq 0  ]]; then
    echo "Based on https://github.com/netvolt/LinuxRMM-Script/blob/main/rmmagent-linux.sh"
    echo ""
    echo "install :"
    echo "./install-linux.sh install <system_type> <meshcentral_url> <api_url> <client_id> <site_id> <auth_key> <agent_type> <version>"
    echo "system_type       : 386 amd64 arm arm64"
    echo "meshcentral_url   : url of your meshcentral instance related to Tactical RMM"
    echo "api_url           : url of your Tactical RMM API"
    echo "client_id         : client id to which this agent reports"
    echo "site_id           : client id to which this agent reports"
    echo "auth_key          : auth_key to Tactical RMM"
    echo "agent_type        : 'server or 'workstation'"
    echo "version           : version to install, for example, v2.8.0"
    echo ""
    echo "update :"
    echo "./install-linux.sh update <system_type>"
    echo "system_type       : 386 amd64 arm arm64"
    echo ""
    echo "uninstall :"
    echo "You should only attempt this if the agent removal feature on TacticalRMM is not working."
    echo "./install-linux.sh uninstall <meshcentral_url> <meshcentral_url_id>"
    echo "Arg 1: 'uninstall'"
    echo "Arg 2: meshcentral_url FQDN (i.e. mesh.example.com)"
    echo "Arg 3: meshcentral_url_id (The id needs to have single quotes around it)"
    echo ""
    exit 0
fi

if [[ $1 == "install" && $2 == "" ]]; then
    echo "Argument 2 (system_type) is empty !"
    exit 1
fi

if [[ $1 == "update" && $2 == "" ]]; then
    echo "Argument 2 (system_type) is empty !"
    exit 1
fi

if [[ $1 == "install" && $2 != "amd64" && $2 != "x86" && $2 != "arm64" && $2 != "armv6" ]]; then
    echo "This argument can only be 'amd64' 'x86' 'arm64' 'armv6' !"
    exit 1
fi

if [[ $1 == "install" && $3 == "" ]]; then
    echo "Argument 3 (meshcentral_url URL) is empty !"
    exit 1
fi

if [[ $1 == "install" && $4 == "" ]]; then
    echo "Argument 4 (api_url) is empty !"
    exit 1
fi

if [[ $1 == "install" && $5 == "" ]]; then
    echo "Argument 5 (client_id) is empty !"
    exit 1
fi

if [[ $1 == "install" && $6 == "" ]]; then
    echo "Argument 6 (Site_id) is empty !"
    exit 1
fi

if [[ $1 == "install" && $7 == "" ]]; then
    echo "Argument 7 (auth_key) is empty !"
    exit 1
fi

if [[ $1 == "install" && $8 == "" ]]; then
    echo "Argument 8 (agent_type) is empty !"
    exit 1
fi

if [[ $1 == "install" && $8 != "server" && $8 != "workstation" ]]; then
    echo "First argument can only be 'server' or 'workstation' !"
    exit 1
fi

if [[ $1 == "uninstall" && $2 == "" ]]; then
    echo "Argument 2 (meshcentral_url FQDN) is empty !"
    exit 1
fi

if [[ $1 == "uninstall" && $3 == "" ]]; then
    echo "Argument 3 (meshcentral_url id) is empty !"
    exit 1
fi

## vars
system=$2
mesh_url=$3
rmm_url=$4
rmm_client_id=$5
rmm_site_id=$6
rmm_auth=$7
rmm_agent_type=$8
version=$9
mesh_fqdn=$2
mesh_id=$3

function update_agent() {
        systemctl stop tacticalagent

        cp /tmp/temp_rmmagent /usr/local/bin/rmmagent
        rm /tmp/temp_rmmagent

        systemctl start tacticalagent
}
function install_agent() {
    # cp /tmp/temp_rmmagent /usr/local/bin/rmmagent
    wget "https://github.com/baldoarturo/tacticalrmmagent/releases/download/v2.8.0-unsigned/rmmagent-linux-${system}-${version}-unsigned" -O /tmp/temp_rmmagent
    chmod +x /tmp/temp_rmmagent
    /tmp/temp_rmmagent -m install -api $rmm_url -client-id $rmm_client_id -site-id $rmm_site_id -agent-type $rmm_agent_type -auth $rmm_auth
    rm /tmp/temp_rmmagent
    cat << "EOF" > /etc/systemd/system/tacticalagent.service
[Unit]
Description=Tactical RMM Linux Agent
[Service]
Type=simple
ExecStart=/usr/local/bin/rmmagent -m svc
User=root
Group=roots
Restart=always
RestartSec=5s
LimitNOFILE=1000000
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now tacticalagent
  systemctl start tacticalagent
}

function install_mesh() {
    ## Installing meshcentral_url
    wget -O /tmp/meshagent $mesh_url
    chmod +x /tmp/meshagent
    mkdir /opt/tacticalmesh
    /tmp/meshagent -install --installPath="/opt/tacticalmesh"
    rm /tmp/meshagent
    rm /tmp/meshagent.msh
}

function uninstall_mesh() {
    (wget "https://$mesh_fqdn/meshagents?script=1" -O /tmp/meshinstall.sh || wget "https://$mesh_fqdn/meshagents?script=1" --no-proxy -O /tmp/meshinstall.sh)
    chmod 755 /tmp/meshinstall.sh
    (/tmp/meshinstall.sh uninstall https://$mesh_fqdn $mesh_id || /tmp/meshinstall.sh uninstall uninstall uninstall https://$mesh_fqdn $mesh_id)
    rm /tmp/meshinstall.sh
    rm meshagent
    rm meshagent.msh
}

function uninstall_agent() {
    systemctl stop tacticalagent
    systemctl disable tacticalagent
    rm /etc/systemd/system/tacticalagent.service
    systemctl daemon-reload
    rm /usr/local/bin/rmmagent
    rm /etc/tacticalagent
}

case $1 in
install)
    install_agent
    echo "Tactical Agent Install is done"
    exit 0;;
update)
    update_agent
    echo "Tactical Agent Update is done"
    exit 0;;
uninstall)
    uninstall_agent
    uninstall_mesh
    echo "Tactical Agent Uninstall is done"
    echo "You may need to manually remove the agents orphaned connections on TacticalRMM and MeshCentral"
    exit 0;;
esac