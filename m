From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 25 Jun 2001 17:04:40 +0000
Subject: [Linux-ia64] gcc3.0+binutils2.11.90 binary package for NUE available
Message-Id: <marc-linux-ia64-105590693005756@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I have uploaded the  binary version  the gcc-3.0+binutils(2.11.90)  
cross-compiler for NUE. The tarfile is avaiable from:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/nue-gcc3-010625.tar.gz


IMPORTANT:
 	- you must have the latest release of NUE (dated May 2001) installed. 
	  More specifically, you need to have nue-fs-1.2
 
 	- This will REPLACE your default gcc-2.96 with gcc-3.0. 
	  So careful if you want to roll back.
 
INSTALLATION:
-------------
	
	You can install the package two ways:

	1/ From inside NUE

	   - first make sure that the tarfile is available inside NUE

	   - enter NUE

	   - become root inside NUE

	   - cd / 
	
           - tar zxf path_to_tarfile/nue-gcc3-010625.tar.gz

	2/ From outside NUE

	   - become root
	  
	   - cd /nue
	
           - tar zxf path_to_tarfile/nue-gcc3-010625.tar.gz
	


VERIFY INSTALL:
---------------

	You can easily verify that the install went well:

	- enter NUE

	- type:

	% gcc -v
	Reading specs from /usr/lib/gcc-lib/ia64-hp-linux/3.0/specs
	Configured with: ../gcc-3.0/configure --target=ia64-hp-linux --prefix=/usr --enable-threads=posix
	Thread model: posix
	gcc version 3.0


	% ld --version
	GNU ld 2.11.90
	Copyright 2001 Free Software Foundation, Inc.
	This program is free software; you may redistribute it under the terms of
	the GNU General Public License.  This program has absolutely no warranty.
  	Supported emulations:
   	elf64_ia64

	% objcopy --version
	GNU objcopy 2.11.90
	Copyright 1997, 98, 99, 2000, 2001 Free Software Foundation, Inc.
	This program is free software; you may redistribute it under the terms of
	the GNU General Public License.  This program has absolutely no warranty.


NOTE to GNU-EFI users:
----------------------
	This version of the toolchain (including objcopy) are known to build
	working EFI binaries without requiring any additional patches. So if
	you are developing EFI applications, it is worth upgrading the compiler
	to 3.0.




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

