From: Avi Kivity <avi@qumranet.com>
Date: Sun, 30 Mar 2008 11:42:03 +0000
Subject: Re: [kvm-ia64-devel] [02/17][PATCH] Implement smp_call_function_mask
Message-Id: <47EF7C8B.90902@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFE@pdsmsx415.ccr.corp.intel.com>
In-Reply-To: <42DFA526FC41B1429CE7279EF83C6BDCFF7EFE@pdsmsx415.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Cc: Carsten Otte <cotte@de.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, kvm-devel@lists.sourceforge.net, Jes Sorensen <jes@sgi.com>, virtualization@lists.linux-foundation.org

Zhang, Xiantao wrote:
>  
> diff --git a/include/linux/smp.h b/include/linux/smp.h
> index 55232cc..b71820b 100644
> --- a/include/linux/smp.h
> +++ b/include/linux/smp.h
> @@ -56,6 +56,9 @@ int smp_call_function(void(*func)(void *info), void
> *info, int retry, int wait);
>  
>  int smp_call_function_single(int cpuid, void (*func) (void *info), void
> *info,
>  				int retry, int wait);
> +int smp_call_function_mask(cpumask_t mask,
> +			   void (*func)(void *), void *info,
> +			   int wait);
>  
>   

For all other archs, smp_call_function_mask() is declared in <asm/smp.h> 
so please define it there.  A separate patch can move the declarations 
to <linux/smp.h>, since it makes sense to have just one declaration (and 
the uniprocessor version is declared there anyway).


-- 
error compiling committee.c: too many arguments to function

