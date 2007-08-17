From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 17 Aug 2007 18:47:37 +0000
Subject: Re: [PATCH]forbid ptrace changes psr.ri to 3
Message-Id: <200708171247.37638.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 August 2007 12:44:58 pm Luck, Tony wrote:
> > This confused me, too, because the changelog and comments say
> > "PSR.ri bits 3 are reserved" and "psr.ri bits 11 are reserved".
> >
> > Something like "PSR.ri value 3 is reserved" would have made
> > the intent more clear.
> 
> Is this better?  I'd already re-worded it a bit when I was checking
> into my GIT tree yesterday ... but I can make more changes if this
> is still causing confusion.

I like the changelog a lot, but you might touch up the comment in
the code as well.
> 
> commit f8655358b7a6f527a5b102cb7d36b4eb14414860
> Author: Shaohua Li <shaohua.li@intel.com>
> Date:   Thu Aug 16 10:47:05 2007 -0700
> 
>     [IA64] forbid ptrace changes psr.ri to 3
>     
>     The "ri" field in the processor status register only has defined
>     values of 0, 1, 2.  Do not let ptrace set this to 3.  As with
>     other reserved fields in registers we silently discard the value.
>     
>     Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
> index 00f8032..da031f8 100644
> --- a/arch/ia64/kernel/ptrace.c
> +++ b/arch/ia64/kernel/ptrace.c
> @@ -951,10 +951,14 @@ access_uarea (struct task_struct *child, unsigned long addr,
>  			return 0;
>  
>  		      case PT_CR_IPSR:
> -			if (write_access)
> -				pt->cr_ipsr = ((*data & IPSR_MASK)
> +			if (write_access) {
> +				unsigned long tmp = *data;
> +				/* psr.ri bits 11 are reserved, ignore the change */
> +				if ((tmp & IA64_PSR_RI) = IA64_PSR_RI)
> +					tmp &= ~IA64_PSR_RI;
> +				pt->cr_ipsr = ((tmp & IPSR_MASK)
>  					       | (pt->cr_ipsr & ~IPSR_MASK));
> -			else
> +			} else
>  				*data = (pt->cr_ipsr & IPSR_MASK);
>  			return 0;
>  
> 


