From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 30 Oct 2000 21:55:19 +0000
Subject: [Linux-ia64] gnu-efi-1.1 released
Message-Id: <marc-linux-ia64-105590678205639@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All,

I have uploaded version 1.1 of the gnu-efi package on our FTP site.

This is a minor revision over the 1.0 release. It fixes the problems 
with the small data section (with the new toolchain). Please note that 
to get a working lilo with this toolchain, you still need to use the old 
objcopy binary.

Also some cleanups in the Makefiles to pick up the right headers files. 
Thanks to David Mosberger for those fixes.


IMPORTANT: ACPI support in LILO

	Since 2.4.0-test7 the kernel is doing the ACPI parsing for 
	device enumeration. Therefore the ACPI code in LILO is now obsolete. 
	It will be removed in the next release. 

This new version is available at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-1.1.tgz

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

