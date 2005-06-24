From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 24 Jun 2005 01:12:41 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <42BB5E09.4020606@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Russ,

Russ Anderson wrote:
>  void
> -mca_handler_bh(unsigned long paddr)
> +mca_handler_bh(unsigned long paddr, void *iip, unsigned long ipsr)
>  {
> -	printk(KERN_DEBUG "OS_MCA: process [pid: %d](%s) encounters MCA.\n",
> -		current->pid, current->comm);
> +	printk(KERN_DEBUG "OS_MCA: process [cpu %d, pid: %d, uid: %d, iip: %p, psr: 0x%lx, paddr: 0x%lx](%s) encounters MCA.\n",
> +		smp_processor_id(), current->pid, current->uid, iip, ipsr, paddr, current->
> +comm);

Printing detail would be good.

> +	pmsa = (pal_min_state_area_t *)(sal_to_os_handoff_state->pal_min_state | (6ul<<61));
> +	if (psr1->cpl != 0 || (pmsa->pmsa_iip >= (unsigned long)&interrupt &&
> +			       pmsa->pmsa_iip <  (unsigned long)&interrupt_pnr)) {

It seems that the latter state just means "this was in early of interrupt."
You shoud also make sure that the interrupt has happen in user context, right?

Thanks,
H.Seto

