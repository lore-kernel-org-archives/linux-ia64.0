From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Fri, 22 Jun 2001 17:27:59 +0000
Subject: [Linux-ia64] recipe to build gcc3.0 as a cross-compiler for NUE
Message-Id: <marc-linux-ia64-105590693005751@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is the recipe to build binutils (2.11) and gcc-3.0 release as cross
compile tools for NUE.

IMPORTANT:
	- the recipe assumes you have installed the latest release of 
	  NUE (dated May 2001). More specifically, you need to have nue-fs-1.2

	- The recipe will replace your default gcc-2.96 with gcc-3.0. So careful
	  if you want to roll back.

	- So far it has been tested for compiling kernels. No tests have been
	  done to see if it works for applications.

	- Please read carefully the recipe, especially the step involving
	  xlimits.h

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

		---------------------------------------------------
		Recipe to build gcc-3.0 as a cross-compiler for NUE
		---------------------------------------------------
			  (c) 2001 Hewlett-Packard Company

Pre-requirements:
	- We suppose you have installed the latest release of NUE and especially
	  the nue-fs-1.2 RPM

	- have access to an installed NUE filesystem
	  specifically /nue/usr/include)

	- use a Linux/x86 host that runs with  GLIBC-2.1. 
	  RH7.1 does not qualify here. But RH7 or RH6.x should work.

	- have the gcc-3.0 release and latest binutils (like 2.11.90)  
	  tar files.

	- you will need to install inside NUE, therefore need root privilege

Configuration:
	- we suppose a NUE installation is accessible in /nue

	- we suppose that the directory used to compile binutils and gcc
	  is also visible inside NUE. This means that it must all directories
	  must be created with a path that begins with /nue. 

	  For instance, I can unpack and build the toolchain in 
	  /nue/home/eranian/toolchain and when I enter NUE, the directory is 
	  accessible at /home/eranian/toolchain.


1/ BUILDING BINUTILS
	
	- you must start with the binutils because they are needed by gcc3
	  later on.

	- untar the binutils in a good directory for you. We suppose this
	  creates a directory called binutils.

	- create a directory called binutils-build. It is not recommended
	  to build the binutils in the directory where you have the sources.

	- cd binutils-build

	- execute the configure command as follows:

	% ../binutils/configure --target=ia64-hp-linux --prefix=/usr

	- type make

	- once it is over, you need to remake ld for shared library support:

		% cd ld
		% make clean
		% make LIB_PATH=/lib:/usr/lib:/usr/local/lib/:/usr/ia64-hp-linux/lib 
		% cd ..
		
	- enter NUE (we suppose you will stay in the same directory, in this case)

	- as root make install:

	# make install	

2/ BUILDING GCC3 as a cross-compiler for NUE

	- untar gcc3 source code. We suppose this creates a directory called
	  gcc-3.0

	- edit gcc-3.0/gcc/config/i386/xm-i386.h and  add the following 2 lines:

	#define HOST_BITS_PER_WIDE_INT 64
	#define HOST_WIDE_INT long long

	  IMPORTANT: this is a gross hack that it meant to enable the cross 
	  compile from a 32bits host to a 64bits target. This hack is very 
	  specific to building for Linux/ia64 target and MUST be removed from 
	  the file, should the source code be used for other purposes.

	- create a build directory called gcc-build. gcc3.0 does not build
	  from the directory where the sources are unpacked.

	- cd gcc-build

	- execute the configure command as follows:

	% ../gcc-3.0/configure --target=ia64-hp-linux --prefix=/usr --enable-threads=posix

	- type make

	- It fails with:

	  gcc-build/gcc/xgcc -B/home/eranian/toolchain/gcc-build/gcc/ -B/usr/ia64-hp-linux/bin/ -B/usr/ia64-hp-linux/lib/ -isystem /usr/ia64-hp-linux/include -c -o crtbegin.o -x assembler-with-cpp ../../gcc-3.0/gcc/config/ia64/crtbegin.asm
	  as: unrecognized option `-x'
	  make[1]: *** [crtbegin.o] Error 1
	  make[1]: Leaving directory `/home/eranian/toolchain/gcc-build/gcc'
	  make: *** [all-gcc] Error 2

	- cd gcc

	- type the following:

	% ln -s /nue/usr/bin/ia64-hp-linux-as as

	- Remove the generated xlimits.h. It is not the correct one. 
	  It will be regenerated correctly later.

	% rm xlimits.h


	- stay in the gcc directory and type make again

	% make TCFLAGS="-g -O2 -I/nue/usr/include" SYSTEM_HEADER_DIR=/nue/usr/include

	- It will compile a few files and then die as follows:

	  make[1]: ia64-hp-linux-ar: Command not found

	- Type the following:

	% ln -s /nue/usr/bin/ia64-hp-linux-ar .
	% ln -s /nue/usr/bin/ia64-hp-linux-nm .
 

	- restart make:
	% make TCFLAGS="-g -O2 -I/nue/usr/include" SYSTEM_HEADER_DIR=/nue/usr/include
	

	- It will die again saying:

	  collect2: cannot find `ld'

	- Create the symlink:

	% ln -s /nue/usr/bin/ia64-hp-linux-ld ld

	- Type make:
	% make TCFLAGS="-g -O2 -I/nue/usr/include" SYSTEM_HEADER_DIR=/nue/usr/include

	- It will stop again:

	  gcc-build/gcc/ld: cannot open crti.o: No such file or directory

	- Create additional symlinks

	% ln -s /nue/usr/lib/crti.o .
	% ln -s /nue/usr/lib/crtn.o .
	% ln -s /nue/usr/lib/libc.a .

	- Type make again to restart:
	% make TCFLAGS="-g -O2 -I/nue/usr/include" SYSTEM_HEADER_DIR=/nue/usr/include

	- it will stop again:

	  as: unrecognized option `-Qy'

	- remove as  and ld (which we created earlier)

	% rm as	ld
	
	- continue with make

	% make TCFLAGS="-g -O2 -I/nue/usr/include" SYSTEM_HEADER_DIR=/nue/usr/include

	- You should go all the way to the end now

	- enter NUE (we suppose you will stay in the gcc directory)

	- as root make install:

	# make install

	IMPORTANT: This will partially replace the default 2.96 install.
	However the /usr/lib/gcc-lib/ia64-hp-linux/2.96-ia64-000717 is preserved.
	Unfortunately, there is no easy way to make a non-destructive install.

