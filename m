From: Jim Wilson <wilson@tuliptree.org>
Date: Wed, 07 May 2003 15:14:17 +0000
Subject: Re: [Linux-ia64] Building IA-64 toolchain
Message-Id: <marc-linux-ia64-105590723705654@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 2003-05-07 at 12:03, navin wrote:
> 	I am doing a project on compilers.I have to build gcc for ia64.I 
> did build the binutils .In that case i didn't get any compilation errors.
> HOSTMACHINE=i386 pentium
> TARGETMACHINE=ia64

Gcc includes libraries that require access to the standard C library in
order to build.  You must provide the standard C library yourself
somehow.  You have not done this.

If you only want a compiler for building the kernel, then you don't need
any libraries.  In that case, you are already done.  What you have is
good enough to build a kernel.

If you need a complete gcc build, then you will need a C library.  If
you have access to a running ia64-linux system, the easy way to do this
is to copy the IA-64 linux /usr/include and /usr/lib to the x86 machine,
and then configure using --with-headers= and --with-libs= pointing at
the IA-64 header and library directories respectively.

An alternative method is to try to build gcc and glibc in parallel. 
This is not easy.  Offhand, I don't know how to do it, as I have never
tried to do this.

>  --without-headers

There is no such configure option.  The headers are required, and there
is no way to get around this.

> In file included from ../../gcc-3.2/gcc/libgcc2.c:37:
> ../../gcc-3.2/gcc/tsystem.h:63:19: stdio.h: No such file or directory
> ../../gcc-3.2/gcc/tsystem.h:66:23: sys/types.h: No such file or directory
> In file included from 

The standard C library header files are missing.

Jim


