From: Gerrit Huizenga <gerrit@us.ibm.com>
Date: Mon, 13 Nov 2000 21:38:19 +0000
Subject: Re: [Linux-ia64] Recommended compiler for compiling kernels test10 and upper?
Message-Id: <marc-linux-ia64-105590678205700@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205680@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205680@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I was able to build this toolchain (the lack of pre-existing g++ stuff
on my IA64 machine was a small problem but I ignored it for the time
being).  I installed it into a /usr/gcc1024 hierarchy so as not to
clobber my existing gcc (since I'm not yet moving to glibc 2.2 on
that machine).

Then I could build the kernel (on a Red Hat Linux release 6.93 (Zoot))
release, cut sometime in June, I believe.

Then, I built the kernel with:

HOSTCC=/usr/bin/gcc CC=/usr/gcc1024/bin/gcc make HOSTCC=/usr/bin/gcc CC=/usr/gcc1024/bin/gcc -j 20 > ERRS 2>&1 &

Which seems to work reasonably well.  This allows the cross tools to
build with the native CC (glibc 2.1 based) and the kernel to build
with a recent compiler, which does not care a whit about glibc
support.

The native toolchain on that Red Hat distro does not have unwind
support, impylying no stack tracebacks in panics, kdb, etc.  The newer
gcc works fine, compiles completely, and has wonderful stack
tracebacks.

All this on a 4-proc Lion, running A3 procs and an ancient BIOS/frame
(my B2/B3 upgrade has been deferred for a while).

YMMV.

gerrit

> I am not a kernel expert.  I do not build my own kernels.  I can not tell you
> which compiler versions are best for compiling which kernel versions.
> 
> However, in general, I recommend the most recent toolchain snapshot available
> at  ftp://ftp.cygnus.com/pub/ia64-linux.  These toolchains assume glibc 2.2.
> Unfortunately, sigh, there aren't any glibc 2.2 based OS releases yet, but
> this shouldn't matter if you are just building kernels.
> 
> Jim
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 

