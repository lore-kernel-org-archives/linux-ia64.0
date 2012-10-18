From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 18 Oct 2012 00:23:29 +0000
Subject: RE: [PATCH] KVM: ia64: remove unused variable in kvm_release_vm_pages()
Message-Id: <B6C2EB9186482D47BD0C5A9A483456440333ECD9@SHSMSX101.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <CAPgLHd_Nr6c-odC3OWJg5BYh5GA=iqHbXPJ_6dz6a+N_fH05ow@mail.gmail.com>
In-Reply-To: <CAPgLHd_Nr6c-odC3OWJg5BYh5GA=iqHbXPJ_6dz6a+N_fH05ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wei Yongjun <weiyj.lk@gmail.com>, "avi@redhat.com" <avi@redhat.com>, "mtosatti@redhat.com" <mtosatti@redhat.com>, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>
Cc: "yongjun_wei@trendmicro.com.cn" <yongjun_wei@trendmicro.com.cn>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "kvm-ia64@vger.kernel.org" <kvm-ia64@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "Zhang, Xiantao" <xiantao.zhang@intel.com>

Acked-by: Xiantao Zhang<xiantao.zhang@intel.com>

> -----Original Message-----
> From: Wei Yongjun [mailto:weiyj.lk@gmail.com]
> Sent: Wednesday, October 17, 2012 11:04 PM
> To: avi@redhat.com; mtosatti@redhat.com; Zhang, Xiantao; Luck, Tony; Yu,
> Fenghua
> Cc: yongjun_wei@trendmicro.com.cn; kvm@vger.kernel.org; kvm-
> ia64@vger.kernel.org; linux-ia64@vger.kernel.org
> Subject: [PATCH] KVM: ia64: remove unused variable in
> kvm_release_vm_pages()
> 
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable base_gfn is initialized but never used otherwise, so remove the
> unused variable.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  arch/ia64/kvm/kvm-ia64.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/arch/ia64/kvm/kvm-ia64.c b/arch/ia64/kvm/kvm-ia64.c index
> 8b3a9c0..c71acd7 100644
> --- a/arch/ia64/kvm/kvm-ia64.c
> +++ b/arch/ia64/kvm/kvm-ia64.c
> @@ -1362,11 +1362,9 @@ static void kvm_release_vm_pages(struct kvm
> *kvm)
>  	struct kvm_memslots *slots;
>  	struct kvm_memory_slot *memslot;
>  	int j;
> -	unsigned long base_gfn;
> 
>  	slots = kvm_memslots(kvm);
>  	kvm_for_each_memslot(memslot, slots) {
> -		base_gfn = memslot->base_gfn;
>  		for (j = 0; j < memslot->npages; j++) {
>  			if (memslot->rmap[j])
>  				put_page((struct page *)memslot->rmap[j]);

