From: Michael Madore <mmadore@turbolinux.com>
Date: Wed, 17 Apr 2002 16:20:50 +0000
Subject: [Linux-ia64] Command line options to elilo from bootmanager
Message-Id: <marc-linux-ia64-105590701905469@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Is it possible to pass command line options to elilo from the boot
manager menu?  For example, I would like to invoke elilo from the boot
manager with an alternate configuration file.  I tried using efibootmgr
like so:

efibootmgr -L linux-ram -l "elilo.efi -C elilo-ram.conf" -c -d /dev/sda
-p 2"

but apparently, EFI treats the "-C elilo-ram.conf" as part of the
bootloader command.

Mike

