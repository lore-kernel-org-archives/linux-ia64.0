From: Francis Galiegue <fg@mandrakesoft.com>
Date: Wed, 22 Nov 2000 10:59:29 +0000
Subject: Re: [Linux-ia64] gcc and glibc: big troubles
Message-Id: <marc-linux-ia64-105590678205767@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205756@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205756@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 21 Nov 2000, Jim Wilson wrote:

Jim,

Thanks very much for your complete answer. I'm afraid I'm not as good as you
guys, but I'm doing my best to follow :)

> 
> >/tmp/ccalpirm.s:6579: Internal error, aborting at ../../gas/config/tc-ia64.c
> >line 5190 in errata_nop_necessary_p
> >        if (regno > 16)
> >          abort ();		<----- This one
> 
> This is a bug in the hardware errata workaround patch.  This should be
> 	if (regno >= 64)
> 	  abort ();
> I found this problem in pre-release testing, so it is fixed in the 001117
> release, but I didn't release a separate patch for this bug fix.
> 

OK, I made a patch over the 001124 release... Compiling with it right now.

> 
> You can build specific tools, like gcc, by using
>     make all-gcc
> There are makefile dependencies which will force everything gcc requires
> (opcodes/bfd/binutils/gas/ld) to also be built.  You can build specific
> target libraries, like libstdc++, by using
>     make all-target-libstdc++
> Making all-gcc, all-gdb, and all-target-libstdc++, will probably build
> everything you want.
> 
> You can install specific tools, like gcc, by using
>    make install-gcc
> There are no dependencies here, so you need to separately install everything
> you want, e.g. bfd, binutils, gas, ld, gdb, gcc, target-libstdc++, and maybe
> some other stuff.
> 

Thanks, rebuilding with these right now.

> You can disable building the gdb gui by using --disable-gdbtk
> 

Already in my spec file.

> 
> I like to point out again that my releases are primarily for the Trillian
> group, to enable kernel, glibc, and Linux distribution work.  It was never
> the intent to recommend them to everyone.  I'd rather recommend the compilers
> that come with the Linux distributions, but unfortunately, all IA-64 GNU/Linux
> distributions are still using the old February toolchain, so as a stop gap
> measure I'm making my toolchains available to everyone.  Since you are
> Linux distributor though, you'd probably have to build my toolchain anyways.
> 

Yep, very useful for building from a chroot... Thanks for your time again.

-- 
Francis Galiegue, fg@mandrakesoft.com
"Programming is a race between programmers, who try and make more and more
idiot-proof software, and universe, which produces more and more remarkable
idiots. Until now, universe leads the race"  -- R. Cook


