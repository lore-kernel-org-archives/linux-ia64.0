From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 May 2003 23:38:15 +0000
Subject: Re: [Linux-ia64] Re: new ia64 kernel patch (relative to 2.5.69)
Message-Id: <marc-linux-ia64-105590723705739@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705722@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705722@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 12 May 2003 16:20:09 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>>>>>> On Sun, 11 May 2003 00:02:50 +1000, Keith Owens <kaos@sgi.com> said:
>  Keith> b6 is not in minstate which means it is missing for INIT and
>  Keith> MCA dumps, making it impossible to determine which code was
>  Keith> in contention.
>
>This doesn't make any sense to me.  If it's not in MINSTATE, it's
>preserved across the firmware INIT path.  You may want to take a
>look at how the 2.5 MCA code is handling this.

Preserved but not listed in the INIT/MCA dumps, i.e. on a first cut of
problem diagnosis you are missing the address of the mainline code that
is in contention.  Also not available to code that only gets pt_regs,
e.g. perfmon and any other code that relies on interrupt state to
record where the kernel is spending its time.

>  Keith> Some of the optional code that is added to the contention
>  Keith> path (e.g. exponential backoff) needs more registers.
>  Keith> Changing spinlock.h forces a complete recompile, so predefine
>  Keith> a suitable set of free registers.
>
>I'd like to see that exponential backoff code first.  The old code in
>head.S did exponential backoff with 4 general registers just fine,
>IIRC.

Not just exponential backoff.  Also kdb, checking for hung spinlocks,
calculating spinlock hold time plus any other debugging or performance
monitoring code that we can add now that there is only one copy of the
spinlock contention code.  They all need additional and separate sets
of registers.

Adding debugging or monitoring code for spinlocks should not require a
complete kernel recompile.  It only takes one user to forget to rebuild
or reinstall their modules after changing spinlock.h and you get
Heisenbugs.  Predefining a reasonable list saves us from all that grief
and costs nothing.


