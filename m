From: Jim Wilson <wilson@cygnus.com>
Date: Tue, 21 Nov 2000 19:14:20 +0000
Subject: Re: [Linux-ia64] gcc and glibc: big troubles
Message-Id: <marc-linux-ia64-105590678205759@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>/tmp/ccalpirm.s:6579: Internal error, aborting at ../../gas/config/tc-ia64.c
>line 5190 in errata_nop_necessary_p
>        if (regno > 16)
>          abort ();		<----- This one

This is a bug in the hardware errata workaround patch.  This should be
	if (regno >= 64)
	  abort ();
I found this problem in pre-release testing, so it is fixed in the 001117
release, but I didn't release a separate patch for this bug fix.

>One thing I don't get is: why all this in the toolchain? Why make, why bison,
>why tk, why tcl? Whats more there's no README at all on how to *avoid* having
>them compiled. I tried --without-x, --disable-x but to no avail... Stock bison
>for example works perfectly fine here, so does make. Any solution?

This is the "Cygnus" way of making releases.  This is necessary for "Cygnus"
to make sure that our customers can rebuild our toolchains.  Otherwise,
they may not have the necessary tools (e.g. GNU make), or they may have
incompatible versions of them (tcl/tk).

This style of release is not appropriate for GNU/Linux distributors, but
unfortunately, we are stuck with it for now.  I'd like to get people moved
to FSF style releases as soon as possible, but I couldn't easily do that until
after most of the development work was done.  I expect the next release will be
from the FSF gcc/binutils/gdb sources, so this should not be a problem with
the next release.

tcl/tk/tix/itcl are there for the gdb gui.  This requires the specific versions
of tcl/tk/etc in the toolchain, otherwise you will run into versioning
problems.  The reasons for the rest of the stuff is probably obvious, they
all come standard with linux, but not with SunOS/Solaris/AIX/Irix/NT/etc.

You can build specific tools, like gcc, by using
    make all-gcc
There are makefile dependencies which will force everything gcc requires
(opcodes/bfd/binutils/gas/ld) to also be built.  You can build specific
target libraries, like libstdc++, by using
    make all-target-libstdc++
Making all-gcc, all-gdb, and all-target-libstdc++, will probably build
everything you want.

You can install specific tools, like gcc, by using
   make install-gcc
There are no dependencies here, so you need to separately install everything
you want, e.g. bfd, binutils, gas, ld, gdb, gcc, target-libstdc++, and maybe
some other stuff.

You can disable building the gdb gui by using --disable-gdbtk

You can also disable building stuff by renaming/deleting the directories.
This will work for all of the optional stuff like flex/bison/make/patch/etc
that comes standard with Linux and which are unlikely to suffer versioning
problems.

All of this stuff I just described also works exactly the same way in FSF
gcc/binutils/gdb releases.  We just bundle everything together instead of
shipping everything separately.

There is documentation explaining all of this stuff, but it is maintained
by the documentation group not the engineers, and is usually distributed on
paper.  A "Cygnus" customer would get it, but it is hard to distribute to
everyone trying to use my Trillian releases.

I like to point out again that my releases are primarily for the Trillian
group, to enable kernel, glibc, and Linux distribution work.  It was never
the intent to recommend them to everyone.  I'd rather recommend the compilers
that come with the Linux distributions, but unfortunately, all IA-64 GNU/Linux
distributions are still using the old February toolchain, so as a stop gap
measure I'm making my toolchains available to everyone.  Since you are
Linux distributor though, you'd probably have to build my toolchain anyways.

Jim

