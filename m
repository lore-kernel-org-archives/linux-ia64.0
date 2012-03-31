From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Sat, 31 Mar 2012 22:32:00 +0000
Subject: Re: [PATCH RFC] Simplify the Linux kernel by reducing its state space
Message-Id: <20120331223200.GA32482@n2100.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120331163321.GA15809@linux.vnet.ibm.com>
In-Reply-To: <20120331163321.GA15809@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Sun, Apr 01, 2012 at 12:33:21AM +0800, Paul E. McKenney wrote:
> Although there have been numerous complaints about the complexity of
> parallel programming (especially over the past 5-10 years), the plain
> truth is that the incremental complexity of parallel programming over
> that of sequential programming is not as large as is commonly believed.
> Despite that you might have heard, the mind-numbing complexity of modern
> computer systems is not due so much to there being multiple CPUs, but
> rather to there being any CPUs at all.  In short, for the ultimate in
> computer-system simplicity, the optimal choice is NR_CPUS=0.
> 
> This commit therefore limits kernel builds to zero CPUs.  This change
> has the beneficial side effect of rendering all kernel bugs harmless.
> Furthermore, this commit enables additional beneficial changes, for
> example, the removal of those parts of the kernel that are not needed
> when there are zero CPUs.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

Great work, but I don't think you've gone far enough with this.

What would really help is if you could consolidate all these NR_CPUS
definitions into one place so we don't have essentially the same thing
scattered across all these architectures.  We're already doing this on
ARM across our platforms, and its about time such an approach was taken
across the entire kernel tree.

It looks like the MIPS solution would be the best one to pick.
Could you rework your patch to do this please?

While you're at it, you might like to consider that having zero CPUs
makes all this architecture support redundant, so maybe you've missed
a trick there - according to my count, we could get rid of almost 3
million lines of code from arch.  We could replace all that with a
single standard implementation.

Bah, maybe I shouldn't have pushed that bpf_jit code for ARM after all...
