From: Jes Sorensen <jes@sgi.com>
Date: Mon, 31 Mar 2008 12:33:47 +0000
Subject: Re: [05/17][PATCH] kvm/ia64 : Add head files for kvm/ia64
Message-Id: <47F0DA2B.9070403@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048246@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048246@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Avi Kivity <avi@qumranet.com>, "Luck, Tony" <tony.luck@intel.com>, "Xu, Anthony" <anthony.xu@intel.com>, Akio Takebe <takebe_akio@jp.fujitsu.com>, kvm-devel@lists.sourceforge.net, kvm-ia64-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, virtualization@lists.linux-foundation.org, Carsten Otte <cotte@de.ibm.com>

Hi Xiantao,

More comments.

Zhang, Xiantao wrote:
>>From 696b9eea9f5001a7b7a07c0e58514aa10306b91a Mon Sep 17 00:00:00 2001
> From: Xiantao Zhang <xiantao.zhang@intel.com>
> Date: Fri, 28 Mar 2008 09:51:36 +0800
> Subject: [PATCH] KVM:IA64 : Add head files for kvm/ia64
> 
> ia64_regs: some defintions for special registers
> which aren't defined in asm-ia64/ia64regs.

Please put missing definitions of registers into asm-ia64/ia64regs.h if
they are official definitions from the spec.

> kvm_minstate.h : Marcos about Min save routines.
> lapic.h: apic structure definition.
> vcpu.h : routions related to vcpu virtualization.
> vti.h  : Some macros or routines for VT support on Itanium.
> Signed-off-by: Xiantao Zhang <xiantao.zhang@intel.com>

> +/*
> + * Flushrs instruction stream.
> + */
> +#define ia64_flushrs() asm volatile ("flushrs;;":::"memory")
> +
> +#define ia64_loadrs() asm volatile ("loadrs;;":::"memory")

Please put these into include/asm-ia64/gcc_intrin.h

> +#define ia64_get_rsc()
> \
> +({
> \
> +	unsigned long val;
> \
> +	asm volatile ("mov %0=ar.rsc;;" : "=r"(val) :: "memory");
> \
> +	val;
> \
> +})
> +
> +#define ia64_set_rsc(val)					\
> +	asm volatile ("mov ar.rsc=%0;;" :: "r"(val) : "memory")

Please update the ia64_get/set_reg macros to handle the RSC register
and use those macros.

> +#define ia64_get_bspstore()
> \
> +({
> \
> +	unsigned long val;
> \
> +	asm volatile ("mov %0=ar.bspstore;;" : "=r"(val) :: "memory");
> \
> +	val;
> \
> +})

Ditto for for AR.BSPSTORE

> +#define ia64_get_rnat()
> \
> +({
> \
> +	unsigned long val;
> \
> +	asm volatile ("mov %0=ar.rnat;" : "=r"(val) :: "memory");
> \
> +	val;
> \
> +})

Ditto for AR.RNAT

> +static inline unsigned long ia64_get_itc(void)
> +{
> +	unsigned long result;
> +	result = ia64_getreg(_IA64_REG_AR_ITC);
> +	return result;
> +}

This exists in include/asm-ia64/delay.h

> +static inline void ia64_set_dcr(unsigned long dcr)
> +{
> +	ia64_setreg(_IA64_REG_CR_DCR, dcr);
> +}

Please just call ia64_setreg() in your code rather than defining a
wrapper for it.

> +#define ia64_ttag(addr)
> \
> +({
> \
> +	__u64 ia64_intri_res;
> \
> +	asm volatile ("ttag %0=%1" : "=r"(ia64_intri_res) : "r" (addr));
> \
> +	ia64_intri_res;
> \
> +})

Please add to include/asm-ia64/gcc_intrin.h instead.

> diff --git a/arch/ia64/kvm/lapic.h b/arch/ia64/kvm/lapic.h
> new file mode 100644
> index 0000000..152cbdc
> --- /dev/null
> +++ b/arch/ia64/kvm/lapic.h
> @@ -0,0 +1,27 @@
> +#ifndef __KVM_IA64_LAPIC_H
> +#define __KVM_IA64_LAPIC_H
> +
> +#include "iodev.h"

I don't understand why iodev.h is included here?

> --- /dev/null
> +++ b/arch/ia64/kvm/vcpu.h

The formatting of this file is dodgy, please try and make it comply with
the Linux standards in Documentation/CodingStyle

> +#define _vmm_raw_spin_lock(x)
> \
[snip]
> +
> +#define _vmm_raw_spin_unlock(x)				\

Could you explain the reasoning behind these two macros? Whenever I see
open coded spin lock modifications like these, I have to admit I get a
bit worried.

> +typedef struct kvm_vcpu VCPU;
> +typedef struct kvm_pt_regs REGS;
> +typedef enum { DATA_REF, NA_REF, INST_REF, RSE_REF } vhpt_ref_t;
> +typedef enum { INSTRUCTION, DATA, REGISTER } miss_type;

ARGH! Please see previous mail about typedefs! I suspect this is code
inherited from Xen ? Xen has a lot of really nasty and pointless
typedefs like these :-(

> +static inline void vcpu_set_dbr(VCPU *vcpu, u64 reg, u64 val)
> +{
> +	/* TODO: need to virtualize */
> +	__ia64_set_dbr(reg, val);
> +}
> +
> +static inline void vcpu_set_ibr(VCPU *vcpu, u64 reg, u64 val)
> +{
> +	/* TODO: need to virtualize */
> +	ia64_set_ibr(reg, val);
> +}
> +
> +static inline u64 vcpu_get_dbr(VCPU *vcpu, u64 reg)
> +{
> +	/* TODO: need to virtualize */
> +	return ((u64)__ia64_get_dbr(reg));
> +}
> +
> +static inline u64 vcpu_get_ibr(VCPU *vcpu, u64 reg)
> +{
> +	/* TODO: need to virtualize */
> +	return ((u64)ia64_get_ibr(reg));
> +}

More wrapper macros that really should just use ia64_get/set_reg()
directly in the code.


> diff --git a/arch/ia64/kvm/vti.h b/arch/ia64/kvm/vti.h
> new file mode 100644
> index 0000000..591ab22
[ship]
> +/* -*-  Mode:C; c-basic-offset:4; tab-width:4; indent-tabs-mode:nil -*-
> */

Evil formatting again!

Cheers,
Jes

