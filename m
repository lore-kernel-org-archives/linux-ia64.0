From: Michael Madore <mmadore@turbolinux.com>
Date: Mon, 12 Feb 2001 17:14:27 +0000
Subject: [Linux-ia64] modutils 2.4.2 and USB
Message-Id: <marc-linux-ia64-105590693005137@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have just built kernel 2.4.1 with the IA64 patch, and also the latest
(2.4.2) modutils.  All of the USB options are compiled as modules, with the
exception of USB-Core, which is compiled statically.  After installing
everything, running depmod -a yields:

depmod: Module /lib/modules/2.4.1-010131-1smp/kernel/drivers/usb/acm.o has
an unknown version (2) usb_device table
	It is likely that the kernel structure has changed, if so then
	you probably need a new version of modutils to handle this kernel.
	Check linux/Documentation/Changes.

Is this a known problem?

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

