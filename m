From: Ashok Raj <ashok.raj@intel.com>
Date: Mon, 14 Mar 2005 19:51:33 +0000
Subject: Re: [PATCH] remove redundant irq_affinity definition
Message-Id: <20050314115132.A20568@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503141128.01855.jbarnes@engr.sgi.com>
In-Reply-To: <200503141128.01855.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 14, 2005 at 11:28:01AM -0800, Jesse Barnes wrote:

Hi Jesse

I submitted one for this much earlier, We need to do a little bit more
than removing the static to function properly for cpu hot remove and
to handle /proc/irq writes correctly for iosapic. See post below.

Tony is probably waiting to push this, since it has a generic piece
in this patch, so probably good to go through akpm.

Tony, how do you want to handle this.

http://marc.theaimsgroup.com/?l=linux-ia64&m0687145406182&w=2

-- 
Cheers,
Ashok Raj - Open Source Technology Center

> === arch/ia64/kernel/irq.c 1.55 vs edited ==> --- 1.55/arch/ia64/kernel/irq.c	2005-01-22 15:54:25 -08:00
> +++ edited/arch/ia64/kernel/irq.c	2005-03-14 11:24:20 -08:00
> @@ -97,7 +97,6 @@
>  cpumask_t __cacheline_aligned pending_irq_cpumask[NR_IRQS];
>  static unsigned long pending_irq_redir[BITS_TO_LONGS(NR_IRQS)];
>  
> -static cpumask_t irq_affinity [NR_IRQS] = { [0 ... NR_IRQS-1] = CPU_MASK_ALL };
>  static char irq_redir [NR_IRQS]; // = { [0 ... NR_IRQS-1] = 1 };
>  
>  void set_irq_affinity_info (unsigned int irq, int hwid, int redir)


