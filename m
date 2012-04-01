From: Borislav Petkov <bp@alien8.de>
Date: Sun, 01 Apr 2012 10:04:48 +0000
Subject: Re: [PATCH RFC] Simplify the Linux kernel by reducing its state space
Message-Id: <20120401100448.GD14848@liondog.tnic>
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

Looks good, thanks for doing that.

Btw, I just got confirmation from hw folk that we can actually give you
hardware support for that code with an upcoming CPU which has NR_CPUS=0
cores.

Oh, and additionally, we can disable some of those so getting into the
negative is also doable from the hw perspective, so feel free to explore
that side of the problem too.

ACK.

-- 
Regards/Gruss,
    Boris.
