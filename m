From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Thu, 05 Apr 2001 23:03:33 +0000
Subject: [Linux-ia64] New gnu-efi package and new boot loader available
Message-Id: <marc-linux-ia64-105590693005375@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have uploaded to the HPLabs FTP site a new version of the gnu-efi 
package.  It is available at:
	
	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-2.0.tar.gz

This loader is *REQUIRED* if you want to boot the new 2.4.3 Linux/ia64
kernel from David. Also the other loaders be it ELI or LILO 
(from gnu-efi-1.1 or older) won't be able to boot 2.4.3 either. 
This new loader will not boot kernels prior to 2.4.3.

Many changes have happened in this version on both the EFI library and also 
on the bootloader sides.

This version of the gnu-efi package includes a new version of the boot loader
which represents the merge of ELI and LILO into ELILO. 
Most features of each have been merged. This means that ELI's config 
file (a la LILO/ia-32) is supported, for instance.

Support and development on the bootloader will now focus on this new version.

At this point, this is still an alpha version of the merged code. Many
pieces have to be tested some more also some new features are not quite
there yet (like netbooting or IA-32 support). In a future release the 
new loader  will most likely be released separately.


Here are the major changes to the package:

	- The EFI lib and header files have been updated to EFI Toolkit 1.02

	- The IA-32 support has been fixed
	  (David Mosberger/HP and Michael Johnston/INTEL)

	- lilo has disappeared and is replaced by elilo

New features of elilo:

	- all features found on lilo, except alternate kernel file at this point

	- the config file support from eli

	- support for loading compressed kernel (gzip, new make compressed target).

	- support for uncompress kernel is still present. 

	- Autodetection of kernel formats 

	- fixed support for FPSWA driver installation

Why is it needed for 2.4.3 ?

	- Major changes in the way the kernel is launched have occured:

	  * kernel expects to be started in physical mode now

	  * the boot paramaters (ia64_boot_param) do not use the ZERO_PAGE
	    anymore. They are stored in EFI runtime memory.

	  * Those changes allowed a major cleanup in the loader but also in the
	    kernel. The loader is no more dependent of the memory layout of the
	    kernel and on kernel headers. The SMP initialization is now 
	    symetric, i.e. the same init path is used (smpboot.c is gone).

	- Only elilo has support for those options

Requirements:

	- you need a recent set of binutils, that's important for the BFD
	library and objcopy in particular. Possibly the version coming from the
	CVS repository or the upcoming version 2.11.

	We have experienced some problems on binaries generated with the compiler
	provided by the latest Redhat Fisher release with IA-64. The problems
	are not systematic.

	If EFI has problems loading a generated binary and complains about
	MaxAddress > 0xff.... or you get a 'command not found' then it is likely
	a development tool problem.

	- to make it easier we have included a pre-compiled version of the
	  loader. The file is  elilo/elilo.efi
	
Enjoy,

+--------------------------------------------------------------------+
| Ste'phane ERANIAN                       | Email eranian@hpl.hp.com |
| Hewlett-Packard Laboratories            |                          |
| 1501, Page Mill Road MS 1U-15           |                          |
| Palo  Alto, CA 94303-096                |                          |
| USA                                     |                          |
| Tel : (650) 857-7174                    |                          |
| Fax : (650) 857-5548                    |                          |
+--------------------------------------------------------------------+

