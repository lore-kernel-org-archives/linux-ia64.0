From: Horms <horms@verge.net.au>
Date: Tue, 20 Mar 2007 02:34:28 +0000
Subject: Re: [PATCH] fix an IA64 MCA kdump bug in kdump_init_notifier
Message-Id: <20070320023426.GA12955@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <45FF431C.1040607@sgi.com>
In-Reply-To: <45FF431C.1040607@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 19, 2007 at 07:12:44PM -0700, Jay Lan wrote:
> In my original patch to support MCA in kdump, changes were made to
> kdump_init_notifier() of arch/ia64/kernel/crash.c. But one change
> was somehow incorrectly modified in 2.6.20 to as below:
> 
> >        if ((val = DIE_INIT_MONARCH_ENTER || DIE_INIT_SLAVE_ENTER) &&
> >                 nd->sos->rv_rc = 1)
> >                return NOTIFY_DONE;
> 
> Since DIE_INIT_SLAVE_ENTER is a non-zero value, thus "nd->sos->rv_rc
> =1" is always evaluated. The kdump kernel aborted because nd->sos
> is NULL in (at least some) MCA cases.
> 
> This patch corrects the problem. It was created against 2.6.21-rc4.

Hi Jay,

I think that your fix below does correct a problem,
in that "|| DIE_INIT_SLAVE_ENTER" appears to be quite bogus.
But if you are worried about nd->sos being NULL, is it worth checking
for that explicitly. Or will it always be non-NULL with the code below?

> 
> Signed-Off-By: Jay Lan <jlan@sgi.com>
> 

> Index: linux/arch/ia64/kernel/crash.c
> =================================> --- linux.orig/arch/ia64/kernel/crash.c	2007-03-15 17:20:01.000000000 -0700
> +++ linux/arch/ia64/kernel/crash.c	2007-03-19 17:27:42.102401208 -0700
> @@ -164,7 +164,7 @@ kdump_init_notifier(struct notifier_bloc
>  
>  	nd = (struct ia64_mca_notify_die *)args->err;
>  	/* Reason code 1 means machine check rendezous*/
> -	if ((val = DIE_INIT_MONARCH_ENTER || DIE_INIT_SLAVE_ENTER) &&
> +	if ((val = DIE_INIT_MONARCH_ENTER || val = DIE_INIT_SLAVE_ENTER) &&
>  		 nd->sos->rv_rc = 1)
>  		return NOTIFY_DONE;
>  


-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

