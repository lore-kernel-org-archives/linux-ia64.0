From: Jonathan_Kwahk@Dell.com
Date: Thu, 15 Jun 2000 20:09:11 +0000
Subject: RE: [Linux-ia64] USB Support
Message-Id: <marc-linux-ia64-105590678205149@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205134@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205134@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I think USB keyboard upon boot up and EFI shell is dependent on the firmware
build you have as well as the hardware revision.  I have gotten certain USB
keyboards and mice to work within the BIOS configuration manager and EFI
Shell.   However, when you run ELI vmlinux it'll report an error.  With
PS/2, you get farther along the installation (complete it).

Someone has recommended that I download all the patches and updates,
recompile the kernel, and install it.

So far, USB mouse/keyboard doesn't work IN the installation.  I'm not
talking about the kernel load or the OS itself.  Just the installation.
Turbolinux 0505.

I'll see what happens when I get the updates recompiled.

Jon

-----Original Message-----
From: Johannes Erdfelt [mailto:jerdfelt@valinux.com]
Sent: Thursday, June 15, 2000 12:47 PM
To: Eric Wang
Cc: linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] USB Support


On Thu, Jun 15, 2000, Eric Wang <ericwang25@hotmail.com> wrote:
> During the machine boot up period, the USB keyboard could not work, so you

> should connect both PS/2 and USB Mouse and Keyboard on the machine. After 
> boot up, install TurboLinux build 5.5 (May 5?), it will install the USB 
> keyboard driver. After the installation, start the Turbolinux OS, startx, 
> you will see the USB keyboard is active. But the USB mouse could not work.

"Could not work" is pretty strong language. I don't see any reason why it
could not work. Perhaps it's not just not implemented now?

I know X can work with a USB mouse, but it needs to be configured properly,
including the appropriate device nodes being created.

JE



_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


