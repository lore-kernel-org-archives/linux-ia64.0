From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 21 May 2001 23:50:02 +0000
Subject: [Linux-ia64] gnu-efi-2.5 is available with new elilo bootloader
Message-Id: <marc-linux-ia64-105590693005638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello All,

I have uploaded the latest version of the gnu-efi package for Linux/ia64.
It is available at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-2.5.tar.gz

New in this version:
	- Major updates to ELILO
	- some updates to the IA-32 support in the crt code 

New features of ELILO:
	- Brand new support for configuration files. ELILO now
	  supports many options of LILO/x86 where it makes sense.
	  Parser and logic have been completely rewritten. 
	  New code allows allow for easy extensions.

	- Support for network booting via DHCP and PXE.

	- ELILO behavior is very close to LILO/x86 in terms of autoboot
	  and interactivity with user.

	- Major source tree restructuring for clarity and to prepare
	  for IA-32 code drop.

	- Lots of code cleanups

	- Updated documentation


IMPORTANT REMARKS: 
------------------
	- This version of ELILO will ONLY boot kernel >= 2.4.4 because of
	  changes in memory allocations inside the loader.

	- This is likely going to be the last release where the EFI library
           and the ELILO code will be bundled together as they do not quite
	   evolve at the same pace.

	- To compile this package, you need a recent (>=pre-3.0) version of the
	  toolchain and binutils. I realize that it is not always easy for 
	  everybody to get this version of the toolchain, therefore I have 
	  included a pre-compiled version of elilo in elilo/elilo.efi.

Note on PXE booting:

	- ELILO is capable of booting using a regular DHCP daemon as shipped	
	  on many Linux distributions

	- ELILO also understands the PXE protocol which, at this point, requires
	  a special version of the DHCP daemon produced by ISC (www.isc.org).
	  Mike Johnston at Intel has created the patch and is trying to get it
	  into the next release of ISC's dhcpd.

	- Sample DHCPD config files for both regular and PXE-aware dhcp daemons
	  are included in elilo/docs.

	- To get help on how to configure your machine for netbooting look at
	  elilo/docs/elilo.txt.

Enjoy,

-- 

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

