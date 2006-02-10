From: Stephane Eranian <eranian@hpl.hp.com>
Date: Fri, 10 Feb 2006 13:35:24 +0000
Subject: Re: PMU and timer interrupts
Message-Id: <20060210133524.GE27419@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060209171648.GA26865@frankl.hpl.hp.com>
In-Reply-To: <20060209171648.GA26865@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jack, Tony,

Suposing I move up the PERFMON_VECTOR to 0xf1, it will be in the
top priority class (15) with the following vectors:

> 	#define IA64_MCA_WAKEUP_VECTOR          0xf0    /* MCA wakeup (must be >MCA_RENDEZ_VECTOR) */
> 	#define IA64_IPI_RESCHEDULE             0xfd    /* SMP reschedule */
> 	#define IA64_IPI_VECTOR                 0xfe    /* inter-processor interrupt vector */

The impact will be that, while servicing a PMU interrupt, I will not be able to get:
	-  an MCA interrupt
	-  a reschedule IPI
	-  a generic IPI

Today, the PMU interrupt handler runs with interrupts disabled, as such the situation would not
be different. In fact, we could skip masking/unmasking because we would be in the top class +
TPR masking done by the kernel on interrupt.

Anybody, has a problem with this?

-- 
-Stephane
