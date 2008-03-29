From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Sat, 29 Mar 2008 02:20:48 +0000
Subject: RE: [11/17][PATCH] kvm/ia64: add processor virtulization support.
Message-Id: <42DFA526FC41B1429CE7279EF83C6BDCFF7F61@pdsmsx415.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <89C890DCEA6547takebe_akio@jp.fujitsu.com>
In-Reply-To: <89C890DCEA6547takebe_akio@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Akio Takebe wrote:
> Hi, Xiantao and Anthony
> 
>> +void getfpreg(unsigned long regnum, struct ia64_fpreg *fpval,
>> +				struct kvm_pt_regs *regs)
>> +{
>> +	/* Take floating register rotation into consideration*/
>> +	if (regnum >= IA64_FIRST_ROTATING_FR)
>> +		regnum = IA64_FIRST_ROTATING_FR + fph_index(regs,
>> regnum);
>> +#define CASE_FIXED_FP(reg)			\
>> +	case  (reg) :				\
>> +		ia64_stf_spill(fpval, reg);	\
>> +	break
>> +
>> +	switch (regnum) {
>> +		CASE_FIXED_FP(0);
>> +		CASE_FIXED_FP(1);
>> +		CASE_FIXED_FP(2);
>> +		CASE_FIXED_FP(3);
>> +		CASE_FIXED_FP(4);
>> +		CASE_FIXED_FP(5);
>> +
>> +		CASE_FIXED_FP(6);
>> +		CASE_FIXED_FP(7);
>> +		CASE_FIXED_FP(8);
>> +		CASE_FIXED_FP(9);
>> +		CASE_FIXED_FP(10);
>> +		CASE_FIXED_FP(11);
>> +
> Is this correct ? Though I don't know why xen do so.
> In the case of Xen, the above parts are;
>
> #define CASE_SAVED_FP(reg)                                      \
>         case reg:                                               \
>                 fpval->u.bits[0] = regs->f##reg.u.bits[0];      \
>                 fpval->u.bits[1] = regs->f##reg.u.bits[1];      \
>                 break
> 
>                 CASE_SAVED_FP(6);
>                 CASE_SAVED_FP(7);
>                 CASE_SAVED_FP(8);
>  
Hi, Akio
	Current should be correct, because for every host<-> guest
switch, we switched FPU accordingly.  So the fpu register file is
dedicated for current vm, getting it from physical register should be
right.  But for xen's code, due to lazy fpu save/restore, current fpu
register file maybe not belong to current vcpu, so need to load it from
stack. Thanks
Xiantao 
