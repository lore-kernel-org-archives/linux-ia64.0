From: Adam Parrish <waparris@ncsu.edu>
Date: Thu, 13 Nov 2003 19:26:56 +0000
Subject: Compiling 2.4.20 Kernel for HP zx6000
Message-Id: <marc-linux-ia64-106875180818451@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Community,

I am working on getting a zx6000 Workstation up for a research group
here at NCSU. So far I have had issues with kernel upgrading but I have
finally gotten a working kernel with the exception of the keyboard and
mouse when I boot to the upgraded one. The method I followed was to copy
the old config file from /boot to /usr/src/linux-2.4.20/.config and then
make oldconfig. I then did make menuconfig to unselect modules and make
them statically compiled into the kernel. For some reason modules cause
errors when I do make modules_install. This could be a problem down the
road when I try to get AFS and Kerberos to cooperate, but first things
first let me get the system somewhat current ;] 

Basically my issue is that my mouse and my keyboard give no response
when I boot. I have selected the following options under USB support:

Preliminary USB device filesystem
EHCI HCD (USB 2.0) support
UHCI (Intel....) support
OHCI (Compaq...) support

USB Human Interface Device (full HID) Support
HID input layer support
/dev/hiddev raw HID device support

These are all of the related things I would think that would need to be
enabled in the kernel for my mouse/keyboard to work. And theoretically
as far as I understand this is an exact kernel image of my 2.4.17 kernel
that works. 

If anyone is willing to mail me a working .config file so that I can
recompile this kernel and make it functional on either the 2.4.20 or
2.4.18 kernels I would be immensely appreciative. Thanks in advance for
any and all help.

Cheers,
Adam
 
-- 
Adam Parrish
Asst. Linux Administrator
ECE Dept, North Carolina State University
Office: 919.515.0124

