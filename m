From: Carsten Otte <cotte@de.ibm.com>
Date: Mon, 31 Mar 2008 13:41:41 +0000
Subject: Re: [01/17]PATCH  Add API for allocating dynamic TR resouce. V8
Message-Id: <47F0EA15.9030408@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC0104823F@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC0104823F@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Jes Sorensen <jes@sgi.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org

Zhang, Xiantao wrote:
> +/*  mca_insert_tr
> + *
> + *  Switch rid when TR reload and needed!
> + *  iord: 1: itr, 2: itr;
> + *
> +*/
> +static void mca_insert_tr(u64 iord)
> +{
> +
> +	int i;
> +	u64 old_rr;
> +	struct ia64_tr_entry *p;
> +	unsigned long psr;
> +	int cpu = smp_processor_id();
What if CONFIG_PREEMPT is on, and we're being preempted and scheduled 
to a different CPU here? Are we running preempt disabled here? If so, 
the function header should state that this function needs to be called 
preempt_disabled.

> +/*
> + * ia64_insert_tr in virtual mode. Allocate a TR slot
> + *
> + * target_mask : 0x1 : itr, 0x2 : dtr, 0x3 : idtr
> + *
> + * va 	: virtual address.
> + * pte 	: pte entries inserted.
> + * log_size: range to be covered.
> + *
> + * Return value:  <0 :  error No.
> + *
> + *		  >=0 : slot number allocated for TR.
> + */
> +int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size)
> +{
> +	int i, r;
> +	unsigned long psr;
> +	struct ia64_tr_entry *p;
> +	int cpu = smp_processor_id();
Same here.

> +/*
> + * ia64_purge_tr
> + *
> + * target_mask: 0x1: purge itr, 0x2 : purge dtr, 0x3 purge idtr.
> + *
> + * slot: slot number to be freed.
> + */
> +void ia64_ptr_entry(u64 target_mask, int slot)
> +{
> +	int cpu = smp_processor_id();
> +	int i;
> +	struct ia64_tr_entry *p;
Here again.


