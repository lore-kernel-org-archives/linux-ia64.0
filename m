From: Carsten Otte <cotte@de.ibm.com>
Date: Mon, 31 Mar 2008 13:46:32 +0000
Subject: Re: [03/15][PATCH] kvm/ia64: Add header files for kvm/ia64. V8
Message-Id: <47F0EB38.2090700@de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048243@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDC01048243@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, kvm-devel@lists.sourceforge.net, Jes Sorensen <jes@sgi.com>, Avi Kivity <avi@qumranet.com>, virtualization@lists.linux-foundation.org

Zhang, Xiantao wrote:
> +typedef union context {
> +	/* 8K size */
> +	char	dummy[KVM_CONTEXT_SIZE];
> +	struct {
> +		unsigned long       psr;
> +		unsigned long       pr;
> +		unsigned long       caller_unat;
> +		unsigned long       pad;
> +		unsigned long       gr[32];
> +		unsigned long       ar[128];
> +		unsigned long       br[8];
> +		unsigned long       cr[128];
> +		unsigned long       rr[8];
> +		unsigned long       ibr[8];
> +		unsigned long       dbr[8];
> +		unsigned long       pkr[8];
> +		struct ia64_fpreg   fr[128];
> +	};
> +} context_t;
This looks ugly to me. I'd rather prefer to have a straight struct 
with elements psr...fr[], and cast the pointer to char* when needed. 
KVM_CONTEXT_SIZE can be used as parameter to kzalloc() on allocation, 
it's too large to be on stack anyway.

> +typedef struct thash_data {
> +	union {
> +		struct {
> +			unsigned long p    :  1; /* 0 */
> +			unsigned long rv1  :  1; /* 1 */
> +			unsigned long ma   :  3; /* 2-4 */
> +			unsigned long a    :  1; /* 5 */
> +			unsigned long d    :  1; /* 6 */
> +			unsigned long pl   :  2; /* 7-8 */
> +			unsigned long ar   :  3; /* 9-11 */
> +			unsigned long ppn  : 38; /* 12-49 */
> +			unsigned long rv2  :  2; /* 50-51 */
> +			unsigned long ed   :  1; /* 52 */
> +			unsigned long ig1  : 11; /* 53-63 */
> +		};
> +		struct {
> +			unsigned long __rv1 : 53;     /* 0-52 */
> +			unsigned long contiguous : 1; /*53 */
> +			unsigned long tc : 1;         /* 54 TR or TC */
> +			unsigned long cl : 1;
> +			/* 55 I side or D side cache line */
> +			unsigned long len  :  4;      /* 56-59 */
> +			unsigned long io  : 1;	/* 60 entry is for io or
> not */
> +			unsigned long nomap : 1;
> +			/* 61 entry cann't be inserted into machine
> TLB.*/
> +			unsigned long checked : 1;
> +			/* 62 for VTLB/VHPT sanity check */
> +			unsigned long invalid : 1;
> +			/* 63 invalid entry */
> +		};
> +		unsigned long page_flags;
> +	};                  /* same for VHPT and TLB */
> +
> +	union {
> +		struct {
> +			unsigned long rv3  :  2;
> +			unsigned long ps   :  6;
> +			unsigned long key  : 24;
> +			unsigned long rv4  : 32;
> +		};
> +		unsigned long itir;
> +	};
> +	union {
> +		struct {
> +			unsigned long ig2  :  12;
> +			unsigned long vpn  :  49;
> +			unsigned long vrn  :   3;
> +		};
> +		unsigned long ifa;
> +		unsigned long vadr;
> +		struct {
> +			unsigned long tag  :  63;
> +			unsigned long ti   :  1;
> +		};
> +		unsigned long etag;
> +	};
> +	union {
> +		struct thash_data *next;
> +		unsigned long rid;
> +		unsigned long gpaddr;
> +	};
> +} thash_data_t;
A matter of taste, but I'd prefer unsigned long mask, and
#define MASK_BIT_FOR_PURPUSE over bitfields. This structure could be 
much smaller that way.

> +struct kvm_regs {
> +	char *saved_guest;
> +	char *saved_stack;
> +	struct saved_vpd vpd;
> +	/*Arch-regs*/
> +	int mp_state;
> +	unsigned long vmm_rr;
> +	/* TR and TC.  */
> +	struct thash_data itrs[NITRS];
> +	struct thash_data dtrs[NDTRS];
> +	/* Bit is set if there is a tr/tc for the region.  */
> +	unsigned char itr_regions;
> +	unsigned char dtr_regions;
> +	unsigned char tc_regions;
> +
> +	char irq_check;
> +	unsigned long saved_itc;
> +	unsigned long itc_check;
> +	unsigned long timer_check;
> +	unsigned long timer_pending;
> +	unsigned long last_itc;
> +
> +	unsigned long vrr[8];
> +	unsigned long ibr[8];
> +	unsigned long dbr[8];
> +	unsigned long insvc[4];		/* Interrupt in service.  */
> +	unsigned long xtp;
> +
> +	unsigned long metaphysical_rr0; /* from kvm_arch (so is pinned)
> */
> +	unsigned long metaphysical_rr4;	/* from kvm_arch (so is pinned)
> */
> +	unsigned long metaphysical_saved_rr0; /* from kvm_arch
> */
> +	unsigned long metaphysical_saved_rr4; /* from kvm_arch
> */
> +	unsigned long fp_psr;       /*used for lazy float register */
> +	unsigned long saved_gp;
> +	/*for phycial  emulation */
> +};
This looks like it does'nt just have guest register content in it. It 
seems to me preferable to have another ioctl different from 
KVM_GET_REGS/KVM_SET_REGS to read and set the rest of the content and 
seperate it from struct kvm_regs.

