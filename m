From: Russ Anderson <rja@sgi.com>
Date: Mon, 09 Feb 2009 23:52:33 +0000
Subject: Re: [PATCH v2 1/2] Revert "[IA64] prevent ia64 from invoking irq handlers on offline CPUs"
Message-Id: <20090209235233.GA6235@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090209181338.GD19064@ldl.fc.hp.com> <20090209181616.GE19064@ldl.fc.hp.com> <20090209211743.GA3939@ldl.fc.hp.com> <20090209233324.GE3939@ldl.fc.hp.com>
In-Reply-To: <20090209233324.GE3939@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>, tony.luck@intel.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
Cc: rja@sgi.com

On Mon, Feb 09, 2009 at 04:33:24PM -0700, Alex Chiang wrote:
> 
> I'm a little closer to understanding why the original revert
> survives my test though.
> 
> It seems that during ia64_process_pending_intr(), we will skip
> TLB flushes, and IPI reschedules.
> 
> Vectors lower than IA64_TIMER_VECTOR are masked (because we raise
> the TPR), meaning we won't see CMC/CPE interrupts or perfmon
> interrupts.
> 
> This leaves only IPIs and MCA above IA64_TIMER_VECTOR. The kernel
> doesn't actually send many IPIs to itself, so in practice, we
> almost never see those.  If we receive an MCA interrupt, well, we
> have more problems to worry about than taking a CPU offline (and
> whatever implications it may have on RCU). So I'm not concerned
> there.

Keep in mind there are recoverable MCAs on ia64.  It should
be a rare condition to have an MCA surface while taking a CPU
offline, but it could happen.

My main point is to make sure people do not assume that an MCA means
the system is going down.  

> The upshot is that in practice, we pretty much ever only need to
> handle the timer interrupt.

Thanks.
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
