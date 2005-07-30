From: Chuck Ebbert <76306.1226@compuserve.com>
Date: Sat, 30 Jul 2005 23:26:40 +0000
Subject: Re: [sched, patch] better wake-balancing, #2
Message-Id: <200507301929_MC3-1-A601-D4C2@compuserve.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050729150207.GA6332@elte.hu>
In-Reply-To: <20050729150207.GA6332@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>

On Fri, 29 Jul 2005 at 17:02:07 +0200, Ingo Molnar wrote:

> do wakeup-balancing only if the wakeup-CPU is idle.
>
> this prevents excessive wakeup-balancing while the system is highly
> loaded, but helps spread out the workload on partly idle systems.

I tested this with Volanomark on dual-processor PII Xeon -- the
results were very bad:

Before: 5863 messages per second

124169 schedule                                  64.1369
 64663 _spin_unlock_irqrestore                  4041.4375
  7949 tcp_clean_rtx_queue                        6.5370
  6787 net_rx_action                             24.9522
 
After: 5569 messages per second

139417 schedule                                  72.0129
 82169 _spin_unlock_irqrestore                  5135.5625
  9949 tcp_clean_rtx_queue                        8.1817
  7917 net_rx_action                             29.1066

__
Chuck
