From: Roland Dreier <roland@topspin.com>
Date: Mon, 25 Oct 2004 17:21:50 +0000
Subject: What does unwcheck.pl do?
Message-Id: <523c02d87l.fsf@topspin.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I build an ia64 kernel, I get a warning about ia64_monarch_init_handler:

	$ make O=../kbuild-ia64
	  Using /data/home/roland/Src/linux-2.6.9 as source for kernel
	  CHK     include/linux/version.h
	make[2]: rch/ia64/kernel/asm-offsets.s' is up to date.
	  CHK     include/asm-ia64/offsets.h
	  CHK     include/linux/compile.h
	ERROR: ia64_monarch_init_handler: 186 slots, total region length = 0
	1 error detected in 9381 functions.
	make[1]: [unwcheck] Error 1 (ignored)
	  Building modules, stage 2.
	  MODPOST

This is with gcc 3.4.1/binutils 2.15 (built with Dan Kegel's crosstool):

	$ ${CROSS_COMPILE}gcc --version
	ia64-unknown-linux-gnu-gcc (GCC) 3.4.1
	Copyright (C) 2004 Free Software Foundation, Inc.
	This is free software; see the source for copying conditions.  There is NO
	warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	$ ${CROSS_COMPILE}ld --version
	GNU ld version 2.15
	Copyright 2002 Free Software Foundation, Inc.
	This program is free software; you may redistribute it under the terms of
	the GNU General Public License.  This program has absolutely no warranty.

I can see the ERROR: comes from unwcheck.pl but I have no idea what it
is checking (something to do with unwind info?) let alone how to fix
the problem.

Is this benign or is there something to be fixed?

Thanks,
  Roland
