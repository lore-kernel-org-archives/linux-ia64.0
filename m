From: Stephane Eranian <eranian@cello.hpl.hp.com>
Date: Thu, 23 Mar 2000 22:40:54 +0000
Subject: [Linux-ia64] GNU-EFI-0.8 is available
Message-Id: <marc-linux-ia64-105590678204994@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I just made available from the HPLabs external ftp site a new version
of the gnu-efi package which allows you to develop EFI applications
using the GNU tools under Linux.

This package also contains the LILO for EFI/IA64 bootloader.

This new version updates LILO only. Some of the new features are:

        * created a documentation file (lilo.txt)
        * fixed a couple of memory leaks
        * code cleanups
        * created a separate directory for lilo
        * added support for the BOOT_IMAGE argument to kernel
        * default is to build natively now
        * rewrote getopt.c

In this package, I have included a binary for lilo called lilo.efi. 
There seems to be a problem with the current GNU toolchain where some 
binaries don't get recognized properly by EFI. I will try to track this 
down some more.

Let me know if you're having problems with this version.

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+


