From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 08 Dec 2003 05:30:00 +0000
Subject: Re: [patch] 2.4.23 fix deadlock in ia64_mca_cmc_int_caller
Message-Id: <marc-linux-ia64-107086176219239@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, 2003-12-07 at 22:08, Keith Owens wrote:
> smp_call_function() must not be called from interrupt context (can
> deadlock on tasklist_lock).  Use keventd to call smp_call_function().
> 

Keith,

   Looks good to me, only comment I have would be to tack the below
chunk into ia64_mca_late_init().  Anywhere before setting
cmc_polling_enabled to the correct state should prevent a race.  Thanks
for fixing this.

	Alex

> @@ -2411,3 +2429,12 @@ ia64_mca_disable_cpe_polling(char *str)
>  }
>  
>  __setup("disable_cpe_poll", ia64_mca_disable_cpe_polling);
> +
> +static int __init init_mca(void)
> +{
> +	INIT_TQUEUE(&cmc_disable_tq, ia64_mca_cmc_vector_disable_keventd, NULL);
> +	INIT_TQUEUE(&cmc_enable_tq, ia64_mca_cmc_vector_enable_keventd, NULL);
> +        return 0;
> +}
> +
> +module_init(init_mca)


