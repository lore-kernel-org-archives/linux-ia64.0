From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 08 Oct 2004 13:51:29 +0000
Subject: Re: cross-compiling glibc-2.2.5/linux-2.6.8 fails due to lack of offsets.h?
Message-Id: <3561.1097243489@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <41664FF7.4090606@kegel.com>
In-Reply-To: <41664FF7.4090606@kegel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 08 Oct 2004 01:29:43 -0700, 
Dan Kegel <dank@kegel.com> wrote:
>In Sept 2003, Keith Owens wrote
>(archived at http://www.gelato.unsw.edu.au/linux-ia64/0309/6667.html):
>
> > 2.4.22 deleted include/asm-ia64/offsets.h from the kernel tree.  If
> > there is no other copy of that file on the include paths (say for cross
> > compiling) then make dep breaks, offsets.h is required before you can
> > build offsets.h.
>
>That looks related to something I just ran into.
>
>I'm going through the matrix
>http://www.kegel.com/crosstool/crosstool-0.28-rc37/buildlogs/0.28/
>trying to fix up all the broken combinations of gcc/glibc/linux/arch
>(not going to any great lengths, just getting the odd patch from
>cvs, usually).  Some of these combinations aren't likely to be
>too useful, but what the heck.
>
>When cross-building linux-2.6.8 for ia64 with glibc-2.2.5, I just ran into the error
>
>In file included from /opt/crosstool/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/ia64-unknown-linux-gnu/include/linux/ptrace.h:49,
>                  from /opt/crosstool/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/ia64-unknown-linux-gnu/include/asm/user.h:31,
>                  from /opt/crosstool/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/ia64-unknown-linux-gnu/include/linux/user.h:1,
>                  from ../sysdeps/unix/sysv/linux/sys/user.h:1,
>                  from ../sysdeps/unix/sysv/linux/ia64/sys/procfs.h:31,
>                  from ../linuxthreads_db/proc_service.h:20,
>                  from ../linuxthreads_db/thread_dbP.h:6,
>                  from internals.h:36,
>                  from attr.c:23:
>/opt/crosstool/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/ia64-unknown-linux-gnu/include/asm/ptrace.h:60:25: asm/offsets.h: No such file or directory
>make[2]: *** [/home/dank/wk/crosstool-0.28-rc38/build/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/build-glibc/linuxthreads/attr.o] Error 1
>make[2]: Leaving directory `/home/dank/wk/crosstool-0.28-rc38/build/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/glibc-2.2.5/linuxthreads'
>make[1]: *** [linuxthreads/others] Error 2
>make[1]: Leaving directory `/home/dank/wk/crosstool-0.28-rc38/build/ia64-unknown-linux-gnu/gcc-3.3.4-glibc-2.2.5/glibc-2.2.5'
>make: *** [all] Error 2
>
>Somehow I don't get this error when building with glibc-2.3.2 or newer,
>dunno why.
>
>I'll probably give up on glibc-2.2.5 for ia64 for now
>unless somebody happens to point me towards a fix.

include/asm-ia64/offsets.h is generated and is per kernel build
specific, which makes it pointless to store it in glibc.  Unfortunately
there are a couple of glibc header files that include asm/offsets.h,
even when not building the kernel.

The glibc headers should be corrected to skip the kernel specific code.
As a quick and dirty workaround, it might be easier to do what the
kernel does to work around the recursive dependency.  Create a dummy
include/asm/offsets.h containing just this line.

#define IA64_TASK_SIZE 0

