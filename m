From: Jiri Kosina <jkosina@suse.cz>
Date: Wed, 27 Mar 2013 13:19:42 +0000
Subject: Re: [PATCH][RESEND] [IA64] tiocx: check retval from bus_register()
Message-Id: <alpine.LNX.2.00.1303271419200.23442@pobox.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LNX.2.00.1303191035010.9529@pobox.suse.cz>
In-Reply-To: <alpine.LNX.2.00.1303191035010.9529@pobox.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 19 Mar 2013, Jiri Kosina wrote:

> Properly check return value from bus_register() and propagate it out of 
> tiocx_init() in case of failure.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>

Is anyone please going to apply/nack this, please?

Thanks.

> ---
>  arch/ia64/sn/kernel/tiocx.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/ia64/sn/kernel/tiocx.c b/arch/ia64/sn/kernel/tiocx.c
> index 14c1711..e35f648 100644
> --- a/arch/ia64/sn/kernel/tiocx.c
> +++ b/arch/ia64/sn/kernel/tiocx.c
> @@ -490,11 +490,14 @@ static int __init tiocx_init(void)
>  {
>  	cnodeid_t cnodeid;
>  	int found_tiocx_device = 0;
> +	int err;
>  
>  	if (!ia64_platform_is("sn2"))
>  		return 0;
>  
> -	bus_register(&tiocx_bus_type);
> +	err = bus_register(&tiocx_bus_type);
> +	if (err)
> +		return err;
>  
>  	for (cnodeid = 0; cnodeid < num_cnodes; cnodeid++) {
>  		nasid_t nasid;
> 

-- 
Jiri Kosina
SUSE Labs
