From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 07 Jan 2010 15:27:02 +0000
Subject: RE: [PATCH] __per_cpu_idtrs[] is a memory hog
Message-Id: <EB8593BCECAB3D40A8248BE0B6400A38315E57E6@shzsmsx502.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b44f13d318206dd61@agluck-desktop.sc.intel.com>
In-Reply-To: <4b44f13d318206dd61@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Okay for me! Thanks, Tony! 
Xiantao

Luck, Tony wrote:
> __per_cpu_idtrs is statically allocated ... on CONFIG_NR_CPUS@96
> systems it takes 16MB of memory. This is way too much for a quite
> probably unused facility (only KVM uses dynamic TR registers).
> 
> Change to an array of pointers, and allocate entries as needed on
> a per cpu basis.  Change the name too as the __per_cpu_ prefix is
> confusing (this isn't a classic <linux/percpu.h> type object).
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> ---
> 
> Bjorn found that he couldn't boot a kernel with a few extra drivers
> compiled statically.  Further digging showed that the problem was
> the kernel was too big (max size is controlled by KERNEL_TR_PAGE_SHIFT
> in <asm/pgtable.h> ... currently set to 64MB).
> 
> More digging showed that on a CONFIG_NR_CPUS@96 kernel a full
> quarter 
> of the available kernel space is used by "__per_cpu_idtrs".
> 
> diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
> index 85d965c..23cce99 100644
> --- a/arch/ia64/include/asm/tlb.h
> +++ b/arch/ia64/include/asm/tlb.h
> @@ -74,7 +74,7 @@ struct ia64_tr_entry {
>  extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64
>  log_size); extern void ia64_ptr_entry(u64 target_mask, int slot);
> 
> -extern struct ia64_tr_entry
> __per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX]; +extern struct
> ia64_tr_entry *ia64_idtrs[NR_CPUS]; 
> 
>  /*
>   region register macros
> diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
> index 32f2639..378b483 100644
> --- a/arch/ia64/kernel/mca.c
> +++ b/arch/ia64/kernel/mca.c
> @@ -1225,9 +1225,12 @@ static void mca_insert_tr(u64 iord)
>  	unsigned long psr;
>  	int cpu = smp_processor_id();
> 
> +	if (!ia64_idtrs[cpu])
> +		return;
> +
>  	psr = ia64_clear_ic();
>  	for (i = IA64_TR_ALLOC_BASE; i < IA64_TR_ALLOC_MAX; i++) {
> -		p = &__per_cpu_idtrs[cpu][iord-1][i];
> +		p = ia64_idtrs[cpu] + (iord - 1) * IA64_TR_ALLOC_MAX;
>  		if (p->pte & 0x1) {
>  			old_rr = ia64_get_rr(p->ifa);
>  			if (old_rr != p->rr) {
> diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
> index ee09d26..00914da 100644
> --- a/arch/ia64/mm/tlb.c
> +++ b/arch/ia64/mm/tlb.c
> @@ -48,7 +48,7 @@ DEFINE_PER_CPU(u8, ia64_need_tlb_flush);
>  DEFINE_PER_CPU(u8, ia64_tr_num);  /*Number of TR slots in current
>  processor*/ DEFINE_PER_CPU(u8, ia64_tr_used); /*Max Slot number used
> by kernel*/ 
> 
> -struct ia64_tr_entry __per_cpu_idtrs[NR_CPUS][2][IA64_TR_ALLOC_MAX];
> +struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
> 
>  /*
>   * Initializes the ia64_ctx.bitmap array based on max_ctx+1.
> @@ -429,10 +429,16 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64
>  	pte, u64 log_size) struct ia64_tr_entry *p;
>  	int cpu = smp_processor_id();
> 
> +	if (!ia64_idtrs[cpu]) {
> +		ia64_idtrs[cpu] = kmalloc(2 * IA64_TR_ALLOC_MAX *
> +				sizeof (struct ia64_tr_entry), GFP_KERNEL);
> +		if (!ia64_idtrs[cpu])
> +			return -ENOMEM;
> +	}
>  	r = -EINVAL;
>  	/*Check overlap with existing TR entries*/
>  	if (target_mask & 0x1) {
> -		p = &__per_cpu_idtrs[cpu][0][0];
> +		p = ia64_idtrs[cpu];
>  		for (i = IA64_TR_ALLOC_BASE; i <= per_cpu(ia64_tr_used, cpu);
>  								i++, p++) {
>  			if (p->pte & 0x1)
> @@ -444,7 +450,7 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64
>  		pte, u64 log_size) }
>  	}
>  	if (target_mask & 0x2) {
> -		p = &__per_cpu_idtrs[cpu][1][0];
> +		p = ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX;
>  		for (i = IA64_TR_ALLOC_BASE; i <= per_cpu(ia64_tr_used, cpu);
>  								i++, p++) {
>  			if (p->pte & 0x1)
> @@ -459,16 +465,16 @@ int ia64_itr_entry(u64 target_mask, u64 va, u64
>  	pte, u64 log_size) for (i = IA64_TR_ALLOC_BASE; i <
>  		per_cpu(ia64_tr_num, cpu); i++) { switch (target_mask & 0x3) {
>  		case 1:
> -			if (!(__per_cpu_idtrs[cpu][0][i].pte & 0x1))
> +			if (!((ia64_idtrs[cpu] + i)->pte & 0x1))
>  				goto found;
>  			continue;
>  		case 2:
> -			if (!(__per_cpu_idtrs[cpu][1][i].pte & 0x1))
> +			if (!((ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX + i)->pte & 0x1))
>  				goto found;
>  			continue;
>  		case 3:
> -			if (!(__per_cpu_idtrs[cpu][0][i].pte & 0x1) &&
> -				!(__per_cpu_idtrs[cpu][1][i].pte & 0x1))
> +			if (!((ia64_idtrs[cpu] + i)->pte & 0x1) &&
> +			    !((ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX + i)->pte & 0x1))
>  				goto found;
>  			continue;
>  		default:
> @@ -488,7 +494,7 @@ found:
>  	if (target_mask & 0x1) {
>  		ia64_itr(0x1, i, va, pte, log_size);
>  		ia64_srlz_i();
> -		p = &__per_cpu_idtrs[cpu][0][i];
> +		p = ia64_idtrs[cpu] + i;
>  		p->ifa = va;
>  		p->pte = pte;
>  		p->itir = log_size << 2;
> @@ -497,7 +503,7 @@ found:
>  	if (target_mask & 0x2) {
>  		ia64_itr(0x2, i, va, pte, log_size);
>  		ia64_srlz_i();
> -		p = &__per_cpu_idtrs[cpu][1][i];
> +		p = ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX + i;
>  		p->ifa = va;
>  		p->pte = pte;
>  		p->itir = log_size << 2;
> @@ -528,7 +534,7 @@ void ia64_ptr_entry(u64 target_mask, int slot)
>  		return;
> 
>  	if (target_mask & 0x1) {
> -		p = &__per_cpu_idtrs[cpu][0][slot];
> +		p = ia64_idtrs[cpu] + i;
>  		if ((p->pte&0x1) && is_tr_overlap(p, p->ifa, p->itir>>2)) {
>  			p->pte = 0;
>  			ia64_ptr(0x1, p->ifa, p->itir>>2);
> @@ -537,7 +543,7 @@ void ia64_ptr_entry(u64 target_mask, int slot)
>  	}
> 
>  	if (target_mask & 0x2) {
> -		p = &__per_cpu_idtrs[cpu][1][slot];
> +		p = ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX + i;
>  		if ((p->pte & 0x1) && is_tr_overlap(p, p->ifa, p->itir>>2)) {
>  			p->pte = 0;
>  			ia64_ptr(0x2, p->ifa, p->itir>>2);
> @@ -546,8 +552,8 @@ void ia64_ptr_entry(u64 target_mask, int slot)
>  	}
> 
>  	for (i = per_cpu(ia64_tr_used, cpu); i >= IA64_TR_ALLOC_BASE; i--) {
> -		if ((__per_cpu_idtrs[cpu][0][i].pte & 0x1) ||
> -				(__per_cpu_idtrs[cpu][1][i].pte & 0x1))
> +		if (((ia64_idtrs[cpu] + i)->pte & 0x1) ||
> +		    ((ia64_idtrs[cpu] + IA64_TR_ALLOC_MAX + i)->pte & 0x1))
>  			break;
>  	}
>  	per_cpu(ia64_tr_used, cpu) = i;

