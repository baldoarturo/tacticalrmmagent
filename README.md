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

### Installing the agent

Go to the web portal for your TacticalRMM instance, and click Agent > Install Agent

`rmmagent-amd64-v2.5.0 -m install --api https://api.yourdomain.com --client-id 1 --site-id 1 --agent-type workstation --auth <RandomString> --rdp --ping --power`