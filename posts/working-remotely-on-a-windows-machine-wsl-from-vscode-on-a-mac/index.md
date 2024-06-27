---
title: Working Remotely on a Windows Machine from VSCode on a Mac
date: 2020-05-22
# date: May 22, 2020
updatedDate: Jul 30, 2020
slug: working-remotely-on-a-windows-machine-wsl-from-vscode-on-a-mac
---

Now I only need a MacBook (1.3 GHz dual-core i5) to do all my work anywhere, thanks to a powerful workstation provided by the university. Yet the workstation is based on Windows 10 and sitting behind the university VPN. I don't want to use Remote Desktop every time I need to do some coding, so I decided to make it so I can code remotely on the workstation but from the lovely VSCode on my little MacBook.

<!-- more -->

## 1. Set up the Windows 10 host machine

The first step is to enable remote SSH login on the Windows machine. It is now super easy to do with the [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/about). I use the Ubuntu 18.04 LTS distro but other Linux distros should work just fine. This will be the remote environment that I work in. Then I follow the instruction in [SSH on Windows Subsystem for Linux (WSL)](https://www.illuminiastudios.com/dev-diaries/ssh-on-windows-subsystem-for-linux/). The post is in great detail with step-by-step guidance. So I won't repeat it again.

## 2. Set up the VSCode on Mac

The second step is to install the [Remote-SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) on VSCode. Then simply ssh into the Ubuntu environment on Windows 10 host machine using the username and password created for the Ubuntu distro. In my case is `ssh`*`myusername`*`@asgard.econ.usyd.edu.au`. A password prompt will of course kindly show up.

## 3. Use SSH key to avoid using password login

The annoying thing is that each time the window reloads and when I start VSCode, I need to manually type in my lengthy password. The better way must be using a SSH key instead.

To do so, open up the Terminal on the Mac and run:

```bash
ssh-keygen
```

A public-private key pair will be generated as `~/.ssh/id_rsa.pub` and `~/.ssh/id_rsa`. Then we need to tell the host machine that this key can be used to identify myself so i can skip entering password next time:

```bash
ssh-copy-id myusername@asgard.econ.usyd.edu.au
```

It will ask for the password on the host machine to confirm I am who I am. But after this, starting VSCode will never ask my password again. What a relief!

## Lastly...

Because the host machine is inside the university network, I need to first connect to the university VPN, otherwise the host address `asgard.econ.usyd.edu.au` will not resolve. Still, it's really great that I can code and run my programs remotely on the powerful 8-core 16-thread machine without feeling the hotness and noise, which turns out to be really important in the summer of Australia......
