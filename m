From: Jakub Jelinek <jakub@redhat.com>
Date: Tue, 18 Sep 2001 09:39:19 +0000
Subject: [Linux-ia64] Re: PROPOSED: 32/64 bit coexistance
Message-Id: <marc-linux-ia64-105590698805207@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805199@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805199@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 18, 2001 at 05:00:50AM -0400, Theodore Tso wrote:
> On Tue, Sep 18, 2001 at 10:34:50AM +0200, Andreas Jaeger wrote:
> > 
> >    * /lib: consistent scheme for all 32bit systems and x86-64,
> >      sparc64, ppc64, zSeries (s390x).
> > 
> >    * iA64 today has a 32bit emulation mode, but 64bit is the
> >      (only) favored one; Alpha is too long established. (64bit
> >      libs will go to /lib)
> > 
> 
> Does Sparc/Ultrasparc use /lib and /lib64?  Or will this be a change
> for the Ultrasparc platform?

Linux/SPARC uses /lib and /lib64 (dynamic linkers /lib/ld-linux.so.2 and
/lib64/ld-linux.so.2), at least glibc has this in (including /usr/include
headers which are correct for both 32bit and 64bit ports by looking
at preprocessor flags (this is what <bits/wordsize.h> is for, and 
magic /usr/include/asm/BuildASM script which creates asm header stubs from
<asm-sparc/*.h> and <asm-sparc64/*.h> headers)), likewise for gcc (the
default dynamic linker for -m64 is there /lib64/ld-linux.so.2; RHL gcc rpm
even contains patch which changes the -m32 resp. -m64 default based on
whether gcc is running in sparc32(8) compatibility environment, so if one
runs sparc32 /bin/sh and in there types ./configure; make, he'll get 32bit
programs, doing the same outside of sparc32 children will result in 64bit
programs (or libraries)), binutils. But as Red Hat SPARC distribution is in
a bad shape (I'm trying to resurrect it at least a little bit in my spare
time during last week), the 64bit stuff consists just of 64bit glibc, gcc,
libtermcap, gdb) there. I think Debian or SuSE folks have played with 64bit
userland too and might get further, though if I remember Debian folks used
to oppose this /lib and /lib64 scheme when I started using it for sparc64
and wanted to do something else.

	Jakub

