From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 19 Aug 2005 16:20:11 +0000
Subject: debian/testing cannot compile static with gcc3.3.5
Message-Id: <20050819162011.GB6405@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I recently upgraded my system to the latest testing.
Since then, I cannot comile any program with static linking:

$ cc hello.c -o hello -g -static
/usr/bin/ld: __libc_errno: TLS definition in /usr/lib/gcc-lib/ia64-linux/3.3.5/../../../libc.a(errno.o) section .tbss mismatches non-TLS reference in /usr/lib/gcc-lib/ia64-linux/3.3.5/../../../libc.a(check_fds.o)
/usr/lib/gcc-lib/ia64-linux/3.3.5/../../../libc.a: could not read symbols: Bad value
collect2: ld returned 1 exit status

I have the following packages installed. So it seems that somehow libc6.1-dev 
has a problem compared to the shared libc.

ii  binutils       2.16.1-2       The GNU assembler, linker and binary utiliti
ii  binutils-dev   2.16.1-2       The GNU binary utilities (BFD development fi
ii  binutils-doc   2.15-5         Documentation for the GNU assembler, linker
ii  libc6.1        2.3.2.ds1-22   GNU C Library: Shared libraries and Timezone
ii  libc6.1-dbg    2.3.2.ds1-22   GNU C Library: Libraries with debugging symb
ii  libc6.1-dev    2.3.2.ds1-22   GNU C Library: Development Libraries and Hea
ii  libc6.1-pic    2.3.2.ds1-22   GNU C Library: PIC archive library
ii  libc6.1-prof   2.3.2.ds1-22   GNU C Library: Profiling Libraries
ii  gcc            3.3.5-1        The GNU C compiler
ii  gcc-3.3        3.3.5-8        The GNU C compiler
ii  gcc-3.3-base   3.3.5-8        The GNU Compiler Collection (base package)
ii  gcc-3.4        3.4.3-6        The GNU C compiler
ii  gcc-3.4-base   3.4.3-6        The GNU Compiler Collection (base package)
ii  gcc-4.0        4.0.1-2        The GNU C compiler
ii  gcc-4.0-base   4.0.1-2        The GNU Compiler Collection (base package)
ii  libgcc1        4.0.1-2        GCC support library

-- 

-Stephane
