From: Michael Madore <mmadore@turbolinux.com>
Date: Thu, 10 Aug 2000 01:56:35 +0000
Subject: [Linux-ia64] XFree 4.0.1 module loading
Message-Id: <marc-linux-ia64-105590678205301@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have XFree 4.0.1 built on IA64, however I am having an issue with
loadable modules that I would like to address.

Loading individual modules works fine.  Unfortunately, if a module
references a symbol inside another module, the dlopen() call  won't
resolve the symbol.

This is primarily a problem while running XFree86 -configure to create an
initial configure file.  Here is an example:

(II) LoadModule: "mga"
(II) Loading /usr/X11R6/lib/modules/drivers/mga_drv.so
dlopen: /usr/X11R6/lib/modules/drivers/mga_drv.so: undefined symbol:
vgaHWddc1SetSpeed
(EE) Failed to load /usr/X11R6/lib/modules/drivers/mga_drv.so
(II) UnloadModule: "mga"


vgaHWddc1SetSpeed is defined in /usr/X11R6/lib/modules/libvgahw.so

How would dlopen() know to look at that module to resolve the dependency?

Mike Madore
Software Engineer
TurboLinux, Inc.






