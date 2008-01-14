From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 14 Jan 2008 22:49:40 +0000
Subject: Re: [PATCH] Fix unaligned handler for floating point instructions with base update
Message-Id: <200801141549.41075.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC50D9B4@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC50D9B4@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 14 January 2008 10:59:24 am Luck, Tony wrote:
> The compiler team did the hard work for this distilling a problem in
> large fortran application which showed up when applied to a 290MB input
> data set down to this instruction:
> 
> 	ldfd f34=[r17],-8
> 
> Which they noticed incremented r17 by 0x10 rather than decrementing it
> by 8 when the value in r17 caused an unaligned data fault.  I tracked
> it down to some bad instruction decoding in unaligned.c. The code
> assumes that the 'x' bit can determine whether the instruction is
> an "ldf" or "ldfp" ... which it is for opcode=6 (see table 4-29 on
> page 3:302 of the SDM).  But for opcode=7 the 'x' bit is irrelevent,
> all variants are "ldf" instructions (see table 4-36 on page 3:306).
> 
> Note also that interpreting the instruction as "ldfp" means that the
> "paired" floating point register (f35 in the example here) will also
> be corrupted.

This sounds like a case of the kernel corrupting user data.  Are you
pushing this into the distro kernels?  Do you have bugzilla numbers?

> ---
> 
>  arch/ia64/kernel/unaligned.c |   11 +++++++----
>  1 file changed, 7 insertions(+), 4 deletions(-)
> 
> --- a/arch/ia64/kernel/unaligned.c	2007-10-19 16:17:25.000000000 -0700
> +++ b/arch/ia64/kernel/unaligned.c	2008-01-11 13:17:41.877317341 -0800
> @@ -1488,16 +1488,19 @@
>  	      case LDFA_OP:
>  	      case LDFCCLR_OP:
>  	      case LDFCNC_OP:
> -	      case LDF_IMM_OP:
> -	      case LDFA_IMM_OP:
> -	      case LDFCCLR_IMM_OP:
> -	      case LDFCNC_IMM_OP:
>  		if (u.insn.x)
>  			ret = emulate_load_floatpair(ifa, u.insn, regs);
>  		else
>  			ret = emulate_load_float(ifa, u.insn, regs);
>  		break;
>  
> +	      case LDF_IMM_OP:
> +	      case LDFA_IMM_OP:
> +	      case LDFCCLR_IMM_OP:
> +	      case LDFCNC_IMM_OP:
> +		ret = emulate_load_float(ifa, u.insn, regs);
> +		break;
> +
>  	      case STF_OP:
>  	      case STF_IMM_OP:
>  		ret = emulate_store_float(ifa, u.insn, regs);
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


