From: Jonathan_Kwahk@Dell.com
Date: Thu, 15 Jun 2000 22:29:37 +0000
Subject: RE: [Linux-ia64] USB Support
Message-Id: <marc-linux-ia64-105590678205153@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205134@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205134@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've also noticed how certain USB keyboards will hang the system (POST 80:
0x54).
If you hard reset the system, it'll get stuck on Post 80: 0xFF.

Anyways, the BIOS USB support code is broken in certain places.  It may
account for the erratic behavior I've been seeing in the EFI shell with the
USB keyboard (which in turn would affect the Turbolinux 0505 installation).

Jon

-----Original Message-----
From: Johannes Erdfelt [mailto:jerdfelt@valinux.com]
Sent: Thursday, June 15, 2000 3:19 PM
To: Jonathan_Kwahk@exchange.dell.com
Cc: ericwang25@hotmail.com; linux-ia64@linuxia64.org
Subject: Re: [Linux-ia64] USB Support


On Thu, Jun 15, 2000, Jonathan_Kwahk@Dell.com <Jonathan_Kwahk@Dell.com>
wrote:
> I think USB keyboard upon boot up and EFI shell is dependent on the
firmware
> build you have as well as the hardware revision.  I have gotten certain
USB
> keyboards and mice to work within the BIOS configuration manager and EFI
> Shell.   However, when you run ELI vmlinux it'll report an error.  With
> PS/2, you get farther along the installation (complete it).

I'm interested in finding out what errors you're seeing. ELI uses the
standard Text Input protocol which EFI should handle regardless if it's
PS/2 or USB.

> Someone has recommended that I download all the patches and updates,
> recompile the kernel, and install it.

I'll try this as well.

> So far, USB mouse/keyboard doesn't work IN the installation.  I'm not
> talking about the kernel load or the OS itself.  Just the installation.
> Turbolinux 0505.

Gotcha. I haven't tried this. I don't know why this wouldn't work except
for explicitily not compiling in USB for the install kernel.

> I'll see what happens when I get the updates recompiled.

JE


