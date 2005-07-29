From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 29 Jul 2005 08:08:48 +0000
Subject: RE: Add prefetch switch stack hook in scheduler function
Message-Id: <200507290808.j6T88ng08130@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <10462.1122622689@kao2.melbourne.sgi.com>
References: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
In-Reply-To: <200507272207.j6RM7fg18695@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Keith Owens' <kaos@ocs.com.au>, Ingo Molnar <mingo@elte.hu>
Cc: David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Keith Owens wrote on Friday, July 29, 2005 12:38 AM
> BTW, for ia64 you may as well prefetch pt_regs, that is also quite
> large.
> 
> #define MIN_KERNEL_STACK_FOOTPRINT (IA64_SWITCH_STACK_SIZE + IA64_PT_REGS_SIZE)

This has to be carefully done, because you really don't want to overwhelm
number of outstanding L2 cache misses.  It only has a limited amount of
queue and once that is filled, cpu get into L2 recirculate state.  And that
is going to be very painful because it translate into cpu stall cycles.

