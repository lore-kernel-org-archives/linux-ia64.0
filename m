From: Doug Chapman <doug.chapman@hp.com>
Date: Thu, 26 Jul 2007 17:48:56 +0000
Subject: Re: [PATCH] ia64: fix build failure on fs/quota.c
Message-Id: <1185472136.20910.15.camel@dchapman.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1184865329.3825.25.camel@dchapman.boston.redhat.com>
In-Reply-To: <1184865329.3825.25.camel@dchapman.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, vtaras@openvz.org

On Thu, 2007-07-19 at 13:15 -0400, Doug Chapman wrote:
> Fix ia64 build failure on fs/qutoa.c.  A recent patch used the
> type compat_u64 which on ia64 is only available if CONFIG_COMPAT
> is defined.
> 
> 
> From: Tony Luck <tony.luck@intel.com>
> Signed-off-by: Doug Chapman <doug.chapman@hp.com>
> 
> --
> 
> --- a/fs/quota.c
> +++ b/fs/quota.c
> @@ -387,7 +387,7 @@ asmlinkage long sys_quotactl(unsigned int cmd, const char __user *special, qid_t
>         return ret;
>  }
>  
> -#if defined(CONFIG_X86_64) || defined(CONFIG_IA64)
> +#if defined(CONFIG_X86_64) || (defined(CONFIG_IA64) && defined(CONFIG_COMPAT))
>  /*
>   * This code works only for 32 bit quota tools over 64 bit OS (x86_64, ia64)
>   * and is necessary due to alignment problems.
> 
> 

I see that this patch has not been pulled in yet.  I am wondering if I
confused things by sending it to both linux-kernel and linux-ia64 lists
and each expected the other to pull it in?  Sorry if that breaks the
process, I am somewhat new to submitting patches.

Can we see about getting this in?  It will break the build used by
fedora/RHEL for certain and I expect other distro's as well.

thanks,

- Doug


