From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 08 Jul 2004 18:39:53 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200407081139.53679.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, July 8, 2004 11:31 am, Chen, Kenneth W wrote:
> >>>> Jesse Barnes wrote on Thursday, July 08, 2004 11:13 AM
> > >
> > > Jesse, do you know if unapplying the "move current to region 5" patch
> > > fixes your boot-problem?  For convenience, I attached the (original)
> > > patch below.
> >
> > Applying this small patch to head.S gets me as far as Grant's original
> > report.
> >
> > -(isBP) br.cond.dpnt .load_current
> > +//(isBP)       br.cond.dpnt .load_current
> >
> > This lets me get to:
> >
> > PID hash table entries: 4096 (order 12: 65536 bytes)
> > CPU 0: base freq 0.000MHz, ITC ratio/2, ITC freq00.000MHz+/--1ppm
> > Console: colour dummy device 80x25
> >
> > And like I've already mentioned, if I revert the whole thing the kernel
> > boots fine.  Ugg, I'm really starting to dislike the move of the
> > init_task...
>
> It is something related to stack pointer (r12).  If sp stays in region 7
> (providing there is a corresponding dtr mapping), kernel boots fine.  David
> mentioned that MCA code also has tpa thingy in it that needs to be
> converted. One other thing I'm getting frustrated at is I'm keep on
> receiving mca while doing a ptc.e (only on sgi altix).  Have no idea why.

I get different behavior depending on whether I'm on a partitioned system or 
not: either a machine check caused by a null pointer dereference in the 
unwind code on a non-partitioned machine, or a hang on a partitioned machine.
  
The difference could be in leftover tc entries from the PROM.  They'll get 
purged when the first ptc.e happens, causing a fault on the very next 
instruction or data reference following the purge.  Just a guess.

Jesse
