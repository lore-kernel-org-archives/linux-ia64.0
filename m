From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 22 May 2008 03:45:21 +0000
Subject: Re: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <20080522034521.GD922%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <4832A0A6.8050800@sgi.com>
In-Reply-To: <4832A0A6.8050800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Jes.

Good catch.
I thought similar fix is necessary for xen/ia64 and checked the code.
It was fixed differently. I think the unnecessary divergence is undesirable.
What do you think the following fix according?


Only copy in the data actually requested by the instruction emulation
and zero pad the destination register first. This avoids the problem
where emulated mmio access got garbled data from ld2.acq instructions
in the vga console driver.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: Jes Sorensen <jes@sgi.com>

diff --git a/arch/ia64/kvm/mmio.c b/arch/ia64/kvm/mmio.c
index 351bf70..e6f194a 100644
--- a/arch/ia64/kvm/mmio.c
+++ b/arch/ia64/kvm/mmio.c
@@ -154,6 +154,9 @@ static void mmio_access(struct kvm_vcpu *vcpu, u64 src_pa, u64 *dest,
 	p->u.ioreq.dir = dir;
 	if (dir = IOREQ_WRITE)
 		p->u.ioreq.data = *dest;
+	else
+		/* it's necessary to ensure zero extending */
+		p->u.ioreq.data = 0;
 	p->u.ioreq.state = STATE_IOREQ_READY;
 	vmm_transition(vcpu);
 


On Tue, May 20, 2008 at 01:13:50PM +0200, Jes Sorensen wrote:
> Matthew Chapman wrote:
> >Jes,
> >
> >Glad you tracked it down.  Can I suggest rather than using memcpy, a
> >more efficient way might be something like...
> >
> >#define ZERO_EXTEND(x,bits) ((x) & (~0UL >> (64-(bits))))
> >
> >*dest = ZERO_EXTEND(p->u.ioreq.data, 8*s);
> 
> Much nicer indeed!
> 
> Here's a pretty version - Tony will you apply this one instead.
> 
> Cheers,
> Jes
> 
> 

> Only copy in the data actually requested by the instruction emulation
> and zero pad the destination register first. This avoids the problem
> where emulated mmio access got garbled data from ld2.acq instructions
> in the vga console driver.
> 
> Signed-off-by: Jes Sorensen <jes@sgi.com>
> 
> ---
>  arch/ia64/kvm/mmio.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.git/arch/ia64/kvm/mmio.c
> =================================> --- linux-2.6.git.orig/arch/ia64/kvm/mmio.c
> +++ linux-2.6.git/arch/ia64/kvm/mmio.c
> @@ -159,7 +159,8 @@
>  
>  	if (p->u.ioreq.state = STATE_IORESP_READY) {
>  		if (dir = IOREQ_READ)
> -			*dest = p->u.ioreq.data;
> +			/* it's necessary to ensure zero extending */
> +			*dest = p->u.ioreq.data & (~0UL >> (64-(s*8)));
>  	} else
>  		panic_vm(vcpu);
>  out:


-- 
yamahata
