From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Mon, 14 Jan 2019 16:54:55 +0000
Subject: Re: [PATCH] perfmon: use ARRAY_SIZE() macro
Message-Id: <24b5302a-3e6e-0cd4-7521-bedacb7766d9@embeddedor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181225025815.GA25908@embeddedor>
In-Reply-To: <20181225025815.GA25908@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

Friendly ping:

Who can take this, please?

Thanks
--
Gustavo

On 12/24/18 8:58 PM, Gustavo A. R. Silva wrote:
> Use ARRAY_SIZE instead of dividing sizeof array with sizeof an element
> or, as in this particular case, sizeof the structure name.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> ---
>   arch/ia64/kernel/perfmon.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
> index 46bff1661836..b39df5078e19 100644
> --- a/arch/ia64/kernel/perfmon.c
> +++ b/arch/ia64/kernel/perfmon.c
> @@ -4644,7 +4644,7 @@ static pfm_cmd_desc_t pfm_cmd_tab[]={
>   /* 32 */PFM_CMD(pfm_write_ibrs, PFM_CMD_PCLRWS, PFM_CMD_ARG_MANY, pfarg_dbreg_t, NULL),
>   /* 33 */PFM_CMD(pfm_write_dbrs, PFM_CMD_PCLRWS, PFM_CMD_ARG_MANY, pfarg_dbreg_t, NULL)
>   };
> -#define PFM_CMD_COUNT	(sizeof(pfm_cmd_tab)/sizeof(pfm_cmd_desc_t))
> +#define PFM_CMD_COUNT	ARRAY_SIZE(pfm_cmd_tab)
>   
>   static int
>   pfm_check_task_state(pfm_context_t *ctx, int cmd, unsigned long flags)
> 
