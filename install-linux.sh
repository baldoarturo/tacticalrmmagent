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
    echo "Downloading agent for ${system}...."
    wget "https://github.com/baldoarturo/tacticalrmmagent/releases/download/${version}-unsigned/rmmagent-linux-${system}-${version}-unsigned" -O /tmp/rmmagent
    echo "Stopping service..."
    systemctl stop tacticalagent
    echo "Updating..."
    cp /tmp/rmmagent /usr/local/bin/rmmagent
    rm /tmp/rmmagent
    echo "Starting service..."
    systemctl start tacticalagent
}
function install_agent() {
    echo "Downloading agent for ${system}...."
    wget "https://github.com/baldoarturo/tacticalrmmagent/releases/download/${version}-unsigned/rmmagent-linux-${system}-${version}-unsigned" -O /tmp/rmmagent
    chmod +x /tmp/rmmagent
    /tmp/rmmagent -m install -api $rmm_url -client-id $rmm_client_id -site-id $rmm_site_id -agent-type $rmm_agent_type -auth $rmm_auth
    echo "Creating service..."
    rm /tmp/rmmagent
    echo "[Unit]">> /etc/systemd/system/tacticalagent.service
    echo "Description=Tactical RMM Linux Agent">> /etc/systemd/system/tacticalagent.service
    echo "[Service]">> /etc/systemd/system/tacticalagent.service
    echo "Type=simple">> /etc/systemd/system/tacticalagent.service
    echo "ExecStart=/usr/local/bin/rmmagent -m svc">> /etc/systemd/system/tacticalagent.service
    echo "User=root">> /etc/systemd/system/tacticalagent.service
    echo "Group=roots">> /etc/systemd/system/tacticalagent.service
    echo "Restart=always">> /etc/systemd/system/tacticalagent.service
    echo "RestartSec=5s">> /etc/systemd/system/tacticalagent.service
    echo "LimitNOFILE=1000000">> /etc/systemd/system/tacticalagent.service
    echo "KillMode=process">> /etc/systemd/system/tacticalagent.service
    echo "[Install]">> /etc/systemd/system/tacticalagent.service
    echo "WantedBy=multi-user.target">> /etc/systemd/system/tacticalagent.service
    echo "Reloading and enabling service..."
    systemctl daemon-reload
    systemctl enable --now tacticalagent
    echo "Starting service..."
    systemctl start tacticalagent
}

function install_mesh() {
    echo "Downloading Meshcentral agent for ${system}...."
    wget -O /tmp/meshagent $mesh_url
    chmod +x /tmp/meshagent
    mkdir /opt/tacticalmesh
    echo "Installing ..."
    /tmp/meshagent -install --installPath="/opt/tacticalmesh"
    rm /tmp/meshagent
    rm /tmp/meshagent.msh
}

function uninstall_mesh() {
    echo "Downloading uninstaller ..."
    wget "https://$mesh_fqdn/meshagents?script=1" -O /tmp/meshinstall.sh || wget "https://$mesh_fqdn/meshagents?script=1" --no-proxy -O /tmp/meshinstall.sh
    chmod 755 /tmp/meshinstall.sh
    echo "Unstalling ..."
    /tmp/meshinstall.sh uninstall https://$mesh_fqdn $mesh_id || /tmp/meshinstall.sh uninstall uninstall uninstall https://$mesh_fqdn $mesh_id
    rm /tmp/meshinstall.sh
    rm meshagent
    rm meshagent.msh
}

function uninstall_agent() {
    echo "Stopping  service ..."
    systemctl stop tacticalagent
    echo "Disabling service ..."
    systemctl disable tacticalagent
    echo "Removing service ..."
    rm /etc/systemd/system/tacticalagent.service
    echo "Reloading ..."
    systemctl daemon-reload
    echo "Unstalling ..."
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