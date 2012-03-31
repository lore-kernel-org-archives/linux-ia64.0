From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Sat, 31 Mar 2012 22:34:09 +0000
Subject: Re: [PATCH RFC] Simplify the Linux kernel by reducing its state space
Message-Id: <20120331223409.GM2450@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120331163321.GA15809@linux.vnet.ibm.com>
 <1333227608.2325.4054.camel@edumazet-glaptop>
 <20120331212149.GI2450@linux.vnet.ibm.com>
 <4F7782ED.7050407@lkmail.de>
In-Reply-To: <4F7782ED.7050407@lkmail.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Sun, Apr 01, 2012 at 12:19:25AM +0200, Lorenz Kolb wrote:
> With that patchset in mind, I am working on a really huge patch,
> which will greatly simplify the Linux kernel  for the real problem
> of having that number of CPUs.
> 
> That patch will have a lot of changes all over the architectures, so
> what will be the best way to post it? Should I split it architecture
> dependend and into one generic part.
> 
> Currently it is a large blob of millions of changes, but will
> greatly simplify the Linux kernel.

Perhaps a branch on a public git tree?  If you are doing what I suspect
you are, you will end up with a very large patch set.  ;-)

							Thanx, Paul

> Regards,
> 
> Lorenz Kolb
> 
> Am 31.03.2012 23:21, schrieb Paul E. McKenney:
> >On Sat, Mar 31, 2012 at 11:00:08PM +0200, Eric Dumazet wrote:
> >>On Sun, 2012-04-01 at 00:33 +0800, Paul E. McKenney wrote:
> >>>Although there have been numerous complaints about the complexity of
> >>>parallel programming (especially over the past 5-10 years), the plain
> >>>truth is that the incremental complexity of parallel programming over
> >>>that of sequential programming is not as large as is commonly believed.
> >>>Despite that you might have heard, the mind-numbing complexity of modern
> >>>computer systems is not due so much to there being multiple CPUs, but
> >>>rather to there being any CPUs at all.  In short, for the ultimate in
> >>>computer-system simplicity, the optimal choice is NR_CPUS=0.
> >>>
> >>>This commit therefore limits kernel builds to zero CPUs.  This change
> >>>has the beneficial side effect of rendering all kernel bugs harmless.
> >>>Furthermore, this commit enables additional beneficial changes, for
> >>>example, the removal of those parts of the kernel that are not needed
> >>>when there are zero CPUs.
> >>>
> >>>Signed-off-by: Paul E. McKenney<paulmck@linux.vnet.ibm.com>
> >>>Reviewed-by: Thomas Gleixner<tglx@linutronix.de>
> >>>---
> >>Hmm... I believe you could go one step forward and allow negative values
> >>as well. Antimatter was proven to exist after all.
> >>
> >>Hint : nr_cpu_ids is an "int", not an "unsigned int"
> >>
> >>Bonus: Existing bugs become "must have" features.
> >;-) ;-) ;-)
> >
> >>Of course there is no hurry and this can wait 365 days.
> >James Bottomley suggested imaginary numbers of CPUs some time back,
> >and I suppose there is no reason you cannot have fractional numbers of
> >CPUs, and perhaps irrational numbers as well.  Of course, these last two
> >would require use of floating-point arithmetic (or something similar)
> >in the kernel.  So I guess we have at several years worth.  Over to you
> >for the negative numbers.  ;-)
> >
> >							Thanx, Paul
> >
> >_______________________________________________
> >Linuxppc-dev mailing list
> >Linuxppc-dev@lists.ozlabs.org
> >https://lists.ozlabs.org/listinfo/linuxppc-dev
> 

