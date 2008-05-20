From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Tue, 20 May 2008 10:33:54 +0000
Subject: Re: [patch] fix zero extending for mmio ld1/2/4 emulation in KVM
Message-Id: <20080520103354.GA10290@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <4832A0A6.8050800@sgi.com>
In-Reply-To: <4832A0A6.8050800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes,

Glad you tracked it down.  Can I suggest rather than using memcpy, a
more efficient way might be something like...

#define ZERO_EXTEND(x,bits) ((x) & (~0UL >> (64-(bits))))

*dest = ZERO_EXTEND(p->u.ioreq.data, 8*s);

Matt


On Tue, May 20, 2008 at 11:57:58AM +0200, Jes Sorensen wrote:
> Hi,
>
> This one seems to solve the problem I have been seeing with ld2.acq
> not being zero extended under KVM.
>
> I believe this patch is correct - please shoot me if I am wrong.
>
> Cheers,
> Jes
>

> Only copy in the data actually requested by the instruction emulation
> and zero pad the destination register first. This avoids the problem
> where emulated mmio access got garbled data from ld2.acq instructions
> in the vga console driver.
> 
> Signed-off-by: Jes Sorensen <jes@sgi.com>
> 
> ---
>  arch/ia64/kvm/mmio.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6.git/arch/ia64/kvm/mmio.c
> =================================> --- linux-2.6.git.orig/arch/ia64/kvm/mmio.c
> +++ linux-2.6.git/arch/ia64/kvm/mmio.c
> @@ -158,8 +158,10 @@
>  	vmm_transition(vcpu);
>  
>  	if (p->u.ioreq.state = STATE_IORESP_READY) {
> -		if (dir = IOREQ_READ)
> -			*dest = p->u.ioreq.data;
> +		if (dir = IOREQ_READ) {
> +			*dest = 0;
> +			memcpy(dest, &p->u.ioreq.data, s);
> +		}
>  	} else
>  		panic_vm(vcpu);
>  out:

