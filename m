From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 21 Mar 2001 00:24:23 +0000
Subject: Re: [Linux-ia64] Unwind problem for __attribute__ noreturn
Message-Id: <marc-linux-ia64-105590693005307@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005303@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005303@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm not able to understand any of this.

I'm not a kernel expert.  It has been months since I've booted a kernel that
I built, and much longer since I've booted a kernel that included kdb.
I do not know what the kernel uses the unwind info for.  This question has
been asked on this list by others recently and has not been answered.
If I have to reproduce this problem by building a kernel and running kdb,
then you will have a very long wait before I look at this, since I will fix
everything I know how to fix first.

The comment about "control reaches end of non-void function" warnings doesn't
make sense.  panic() is defined as returning void, so it should not be possible
to get this warning.  I downloaded 2.4.2 today just to be sure, along with
David's 010228 patch.

I tried deleting the NORET_TYPE from the .c file, but I get identical .i
with and without it (disregarding whitespace).  It doesn't seem to do anything.
I tried deleting the noreturn attribute that came from the kernel.h header
file, but doesn't do anything either.  I get identical .s files with or
without it.

If you want me to look at this, you will have to give me something I can
understand.  Preferably a .i file and a gcc command.  But if you want me
to look at a kernel, then you need to tell me what kernel you are using,
what patches you have applied to it, where you got the patches from,
what kernel config file you are using, and what compiler version you are using.
And possibly other stuff that I don't know yet that I need.

I have linux-2.4.2 and David's 010228 patch.  I am looking at the function
panic() in the kernel/panic.c file.  I am using current FSF gcc development
sources.

The only thing that occurs to me at the moment is that maybe the kdb patch
is doing something here that causes the problem.  I've never downloaded the
kdb patch.  Last time I used kdb, it was still part of the ia64-linux kernel
sources.  If I need the kdb patch, where to I get it from?

Jim

