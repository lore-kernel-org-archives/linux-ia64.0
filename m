From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 17 Aug 2001 23:11:17 +0000
Subject: [Linux-ia64] elilo-3.1 is now available
Message-Id: <marc-linux-ia64-105590698805088@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

A new version of elilo is now available for downloads from:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.1.tar.gz


This new version uses the gnu-efi-3.0.tar.gz package. This version
will only load kernel >= 2.4.3.

New in this version:
--------------------
	- possibility to abort (via keypress) on loads of compressed
	  files (like kernel or initrd)

	- possibility to use forward slashes (/) when accessing files
	  on EFI system partitions (FAT32).

	- added support for architecture specific config file options

	- added support for architecture specific command line options
	
	- added support for kernel relocation when the load address is 
	  not available (on memory errors or misconfiguration). This patch
	  was contributed by Brent Casavant from SGI. 

	  The default Linux/ia64 does not support relocation, so you need 
	  a special version. Relocation is only available for IA-64.

	- update to documentation (elilo.txt)

Bug fixes:
----------
	- see changelog


This new version has been tested on bigsur with FW B99b and also B114b.
No testing has been done for EFI/ia32-based systems.

-- 
-Stephane

