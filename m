From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 08 Jul 2004 18:13:20 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200407081113.20527.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tuesday, June 29, 2004 4:18 pm, David Mosberger wrote:
> >>>>> On Tue, 29 Jun 2004 11:19:34 -0700, "Chen, Kenneth W"
> >>>>> <kenneth.w.chen@intel.com> said:
>
>   Ken> Looks like there are more places where kernel does "virt ->
>   Ken> phys -> virt".  And conversion from phys to virt is setting 3
>   Ken> msb to 1.
>
> Your fixes work fine on the machines I have tried so far (variety of
> Itanium 2 boxen and a Big Sur Merced box).
>
> Jesse, do you know if unapplying the "move current to region 5" patch
> fixes your boot-problem?  For convenience, I attached the (original)
> patch below.

Applying this small patch to head.S gets me as far as Grant's original report.

-(isBP) br.cond.dpnt .load_current
+//(isBP)       br.cond.dpnt .load_current

This lets me get to:

PID hash table entries: 4096 (order 12: 65536 bytes)
CPU 0: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz+/--1ppm
Console: colour dummy device 80x25

And like I've already mentioned, if I revert the whole thing the kernel boots 
fine.  Ugg, I'm really starting to dislike the move of the init_task...

Jesse
