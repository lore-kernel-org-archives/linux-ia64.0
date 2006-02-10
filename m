From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 10 Feb 2006 20:33:20 +0000
Subject: RE: PMU and timer interrupts
Message-Id: <200602102033.k1AKXKg25864@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Stephane Eranian wrote on Friday, February 10, 2006 5:35 AM
> Suposing I move up the PERFMON_VECTOR to 0xf1, it will be in the
> top priority class (15) with the following vectors:
> 
> Today, the PMU interrupt handler runs with interrupts disabled,
> as such the situation would not be different. In fact, we could
> skip masking/unmasking because we would be in the top class +
> TPR masking done by the kernel on interrupt.
> 
> Anybody, has a problem with this?

If your goal is to be able to sample timer interrupt with PMU, you
won't get it even after you move PMU vector one class up.  Because
just like PMU vector, timer interrupt handler is run with interrupt
off all the through.

- Ken

