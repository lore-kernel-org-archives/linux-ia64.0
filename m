From: Carsten Otte <cotte@de.ibm.com>
Date: Mon, 31 Mar 2008 15:34:55 +0000
Subject: Re: [05/17][PATCH] kvm/ia64 : Add head files for kvm/ia64
Message-Id: <47F1049F.9030903@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048246@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048246@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, kvm-devel@lists.sourceforge.net, Jes Sorensen <jes@sgi.com>, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org


> +/**********************************************************************
> ****
> +  VCPU control register access routines
> +
> ************************************************************************
> **/
> +static inline u64 vcpu_get_itir(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, itir));
> +}
> +
> +static inline void vcpu_set_itir(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, itir) = val;
> +}
> +
> +static inline u64 vcpu_get_ifa(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, ifa));
> +}
> +
> +static inline void vcpu_set_ifa(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, ifa) = val;
> +}
> +
> +static inline u64 vcpu_get_iva(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, iva));
> +}
> +
> +static inline u64 vcpu_get_pta(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, pta));
> +}
> +
> +static inline u64 vcpu_get_lid(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, lid));
> +}
> +
> +static inline u64 vcpu_get_tpr(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, tpr));
> +}
> +
> +static inline u64 vcpu_get_eoi(VCPU *vcpu)
> +{
> +	return (0UL);		/*reads of eoi always return 0 */
> +}
> +
> +static inline u64 vcpu_get_irr0(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, irr[0]));
> +}
> +
> +static inline u64 vcpu_get_irr1(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, irr[1]));
> +}
> +
> +static inline u64 vcpu_get_irr2(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, irr[2]));
> +}
> +
> +static inline u64 vcpu_get_irr3(VCPU *vcpu)
> +{
> +	return ((u64)VCPU(vcpu, irr[3]));
> +}
> +
> +static inline void vcpu_set_dcr(VCPU *vcpu, u64 val)
> +{
> +	ia64_set_dcr(val);
> +}
> +
> +static inline void vcpu_set_isr(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, isr) = val;
> +}
> +
> +static inline void vcpu_set_lid(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, lid) = val;
> +}
> +
> +static inline void vcpu_set_ipsr(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, ipsr) = val;
> +}
> +
> +static inline void vcpu_set_iip(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, iip) = val;
> +}
> +
> +static inline void vcpu_set_ifs(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, ifs) = val;
> +}
> +
> +static inline void vcpu_set_iipa(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, iipa) = val;
> +}
> +
> +static inline void vcpu_set_iha(VCPU *vcpu, u64 val)
> +{
> +	VCPU(vcpu, iha) = val;
> +}
> +
> +
> +static inline u64 vcpu_get_rr(VCPU *vcpu, u64 reg)
> +{
> +	return vcpu->arch.vrr[reg>>61];
> +}
Looks to me like most of them can be replaced by a few macros using 
macro_##.

> +static inline int highest_bits(int *dat)
> +{
> +	u32  bits, bitnum;
> +	int i;
> +
> +	/* loop for all 256 bits */
> +	for (i = 7; i >= 0 ; i --) {
> +		bits = dat[i];
> +		if (bits) {
> +			bitnum = fls(bits);
> +			return i * 32 + bitnum - 1;
> +		}
> +	}
> +	return NULL_VECTOR;
> +}
duplicate to asm/bitops.h find_first_bit().
