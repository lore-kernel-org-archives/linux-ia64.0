From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Date: Mon, 22 Jul 2019 06:56:14 +0000
Subject: Re: [PATCH] ia64: perfmon: Fix a typo
Message-Id: <a08f8eff-5043-dcf5-b4e1-22c0512bd8d3@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190721165144.3152-1-christophe.jaillet@wanadoo.fr>
In-Reply-To: <20190721165144.3152-1-christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>, tony.luck@intel.com, fenghua.yu@intel.com, david@redhat.com, tglx@linutronix.de, gregkh@linuxfoundation.org, akpm@linux-foundation.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On 21.07.19 18:51, Christophe JAILLET wrote:
> s/permfon.h/perfmon.h/
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> The reference to perfmon.h should maybe be just removed because I've found
> no information about the increasing order to respect.
> This is maybe now in another file?
> ---
>   arch/ia64/kernel/perfmon.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
> index 58a6337c0690..22795b420b10 100644
> --- a/arch/ia64/kernel/perfmon.c
> +++ b/arch/ia64/kernel/perfmon.c
> @@ -4550,7 +4550,7 @@ pfm_exit_thread(struct task_struct *task)
>   }
>   
>   /*
> - * functions MUST be listed in the increasing order of their index (see permfon.h)
> + * functions MUST be listed in the increasing order of their index (see perfmon.h)
>    */
>   #define PFM_CMD(name, flags, arg_count, arg_type, getsz) { name, #name, flags, arg_count, sizeof(arg_type), getsz }
>   #define PFM_CMD_S(name, flags) { name, #name, flags, 0, 0, NULL }
> 

Reviewed-By: Enrico Weigelt <info@metux.net>
-- 
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
