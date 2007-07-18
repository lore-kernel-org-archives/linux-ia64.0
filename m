From: Doug Chapman <doug.chapman@hp.com>
Date: Wed, 18 Jul 2007 21:51:34 +0000
Subject: RE: ia64 build failure from recent diskquota patch
Message-Id: <1184795494.3026.21.camel@deimos.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A01F661D1@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A01F661D1@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, vtaras@openvz.org

On Wed, 2007-07-18 at 14:45 -0700, Luck, Tony wrote:
> > The type compat_u64 on ia64 is defined if CONFIG_COMPAT is defined
> > (which is rare these days on ia64)  So, it appears we are missing
> > an #ifdef CONFIG_COMPAT somewhere in fs/quota.c.  I will leave that
> > up to the original author to determine where.
> 
> Hmmmm ... all of my test config files have CONFIG_COMPAT=y, so I didn't
> notice this.  I'll have to fix one of them to turn it off.
> 
> Perhaps this (untested) is what is needed?
> 
> diff --git a/fs/quota.c b/fs/quota.c
> index e6577ac..ac3af87 100644
> --- a/fs/quota.c
> +++ b/fs/quota.c
> @@ -387,7 +387,7 @@ asmlinkage long sys_quotactl(unsigned int cmd, const char __user *special, qid_t
>  	return ret;
>  }
>  
> -#if defined(CONFIG_X86_64) || defined(CONFIG_IA64)
> +#if defined(CONFIG_X86_64) || (defined(CONFIG_IA64) && defined(CONFIG_COMPAT))
>  /*
>   * This code works only for 32 bit quota tools over 64 bit OS (x86_64, ia64)
>   * and is necessary due to alignment problems.

Works for me, compiles just fine now.

ACK

- Doug


