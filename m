From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 04 Mar 2002 23:20:57 +0000
Subject: [Linux-ia64] elilo-3.2 is now available!
Message-Id: <marc-linux-ia64-105590701905217@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have just released version 3.2 of elilo, the EFI bootloader for
Linux/ia64 and Linux/ia32.

Some of the new features:
-------------------------

	- support for multiple choosers (chooser= option)

	- a new chooser called textmenu, which uses lineart and colors based on
	  the SYSLINUX message syntax. Documentation and examples are included.
          contributution from Richard Hirst from LinuxCare.

	- support for message= and description= in the config file
          contributution from Richard Hirst from LinuxCare.

	- support for f1=,f2=,.....,f12= options to display a file when a 
	  function key is pressed. Textmenu chooser only.
          contributution from Richard Hirst from LinuxCare.

	- a new Linux/ia64 tool, called eliloalt, to create, modify, read the 
	  EliloAlt variable used to specify a kernel to boot only once.

	- added internal elilo substitution variables:
	  now command line arguments can be customized at "boot time", which
	  is very handy when netbooting (get IP address, netmask on the fly)
		
	- enhanced simple chooser:
		- added support for message=, description= 
		- added capability to show what will be passed to the kernel
		  for labels (press TAB after label name)
		- more line editing commands (CTRL-C=kill line, CTRL-U=clean line)
		- pressing '%' shows variables, '?' shows detected boot devices

	- IA-32 support fixed to boot 2.2.x AND 2.4.x (probably 2.5.x as well)
	  Contributions from Mike Johnston and Chris Ahna from Intel 
	 (my personal thanks to you guys!)

	- completely updated documentation. Dedicated document to describe how
	  to boot from the network.

	- a lot of bug fixes

Please look at Changelog for more details.

To compile this package on both IA-32 and IA-64, you need gcc3.x and
binutils 2.11.90 or higher. Also if you're using anything newer than 
gcc3.0 release, you need to grab the updated version of the gnu-efi
package, i.e., gnu-efi-3.0a, because there were some changes in the
way gcc treats constant strings which impact the loader script used
to build elilo. You can grab the package at:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/gnu-efi-3.0a.tar.gz

As usual, I have included precompiled binaries for IA-64 (elilo-ia64.efi)
and IA-32 (elilo-ia32.efi). To try the IA-32 version, you need a PC
with EFI support. This can either be a native EFI implementation or
a PC with a legacy BIOS booted with the EFI floppies from the Intel
sample implementation which you can get at:

	http://developer.intel.com/technology/efi


The new version of elilo can be downloaded from:

	ftp://ftp.hpl.hp.com/pub/linux-ia64/elilo-3.2.tar.gz

The package has the following MD5 checksum:

	c2d0af444571b14b0dca18e5b37592f4  elilo-3.2.tar.gz

Enjoy,

-- 

-Stephane

