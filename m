From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 26 Feb 2005 00:40:19 +0000
Subject: RE: [PATCH] random ia64 sched-domains values
Message-Id: <200502260040.j1Q0eJg10905@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <421EDE70.3010501@yahoo.com.au>
In-Reply-To: <421EDE70.3010501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nick Piggin wrote on Friday, February 25, 2005 12:15 AM
> These are some values I just found from thin-air that should
> hopefully make ia64 work after the latest sched patches.
>
> +#define SD_CPU_INIT (struct sched_domain) {		\
> ...
> +	.max_interval		= 4,			\
> +	.busy_factor		= 64,			\
> +	.imbalance_pct		= 125,			\

For one db workload, performance increases with the following
values compare to the values proposed above.

.max_interval = 100
.busy_factor = 32
.imbalance_pct = 100



