From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Tue, 08 Aug 2000 01:59:43 +0000
Subject: [Linux-ia64] gnu-efi-0.9 released
Message-Id: <marc-linux-ia64-105590678205270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have just released the new 0.9 version of the gnu-efi package. 

This version includes:
	-  a fix to the loader script to get binaries
	   to work correctly (command not found problem).

	- a new version of LILO (the bootoader) with:
		- initial ramdisk support (original ELI code from Red Hat)
		- updated ACPI patches from NEC
		- lots of code cleanups
		- possibility to exit right before jumping into kernel code

Please try it out and let me know if you have problems. To get the initrd
support to work you will need to wait until David releases a new kernel patch
which fixes some alignment issues.

The new package is available from HPLabs ftp site at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-0.9.tar.gz

(PS: if you are having trouble getting to this site, let me know and
I'll send it to you directly).

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

