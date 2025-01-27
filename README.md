### What you will find here
Precompiled releases for every version of the Tactical RMM Agent

I have just automated the build process for every tag, some of they will fail, you are on your own here.

You can find the binaries here
https://github.com/baldoarturo/tacticalrmmagent/releases

Please do support the original project if you use this for commercial applications

https://github.com/amidaware/tacticalrmm

### Builds

Of course these releases are not code-signed so you are at your own risk

You can check the build process at [.github/workflows/ci.yml](.github/workflows/ci.yml)

There are ready to use builds for 
- __Linux__ amd64 386 arm64 arm
- __Windows__ amd64 386
- __MacOS__ amd64 arm64

The naming convention is rmmagent-_platform_-_cpu_
For example, a 64 bit Windows version would be rmmagent-windows-amd64.exe

### Installing the agent manually
We need to recover some data manually from the TacticalRMM server.

Go to the web portal for your TacticalRMM instance, and click Agent > Install Agent.

Select all the options you'd like, but change macOS to Windows, and select manual for installation method. The Arch section can be ignored.

Then click "Show Manual Instructions", and copy beginning at -m install until the end. You should have something like: -m install --api https://api.yourdomain.com --client-id 1 --site-id 1 --agent-type workstation --auth <RandomString> --rdp --ping --power

The <RandomString> is what we will need to feed the installer.

`rmmagent-amd64-v2.5.0 -m install --api https://api.yourdomain.com --client-id 1 --site-id 1 --agent-type workstation --auth <RandomString> --rdp --ping --power`

### Installing the agent with helper scripts

I tried my best to provide some helper scripts for all platforms

- install-linux.sh
- install-macos.sh
- install-windows.bat


```
Based on https://github.com/netvolt/LinuxRMM-Script/blob/main/rmmagent-linux.sh

install :
./install-xxxxxx install <system_type> <meshcentral_url> <api_url> <client_id> <site_id> <auth_key> <agent_type> <version>
system_type       : 386 amd64 arm arm64
meshcentral_url   : url of your meshcentral instance related to Tactical RMM
api_url           : url of your Tactical RMM API
client_id         : client id to which this agent reports
site_id           : client id to which this agent reports
auth_key          : auth_key to Tactical RMM
agent_type        : 'server or 'workstation'
version           : version to install, for example, v2.8.0

update :
./install-xxxxxx update <system_type>
system_type       : 386 amd64 arm arm64

uninstall :
You should only attempt this if the agent removal feature on TacticalRMM is not working.
./install-xxxxxx uninstall <meshcentral_url> <meshcentral_url_id>
meshcentral_url   : FQDN (i.e. mesh.example.com)
meshcentral_url_id: The id needs to have single quotes around it
```
