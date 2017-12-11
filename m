From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Mon, 11 Dec 2017 16:28:35 +0000
Subject: Re: [PATCH 13/13] arc: do not use __print_symbol()
Message-Id: <12708a61-ebc7-8f3f-cef6-4a725047de6d@synopsys.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
 <20171211125025.2270-14-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-14-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 12/11/2017 04:53 AM, Sergey Senozhatsky wrote:
> __print_symbol() uses extra stack space to sprintf() symbol
> information and then to feed that buffer to printk()
>
>    char buffer[KSYM_SYMBOL_LEN];
>
>    sprint_symbol(buffer, address);
>    printk(fmt, buffer);
>
> Replace __print_symbol() with a direct printk("%pS") call.
>
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Cc: Vineet Gupta <vgupta@synopsys.com>

Applied to arc for-curr

Thx,
-Vineet

> ---
>   arch/arc/kernel/stacktrace.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/arc/kernel/stacktrace.c b/arch/arc/kernel/stacktrace.c
> index 74315f302971..bf40e06f3fb8 100644
> --- a/arch/arc/kernel/stacktrace.c
> +++ b/arch/arc/kernel/stacktrace.c
> @@ -163,7 +163,7 @@ arc_unwind_core(struct task_struct *tsk, struct pt_regs *regs,
>    */
>   static int __print_sym(unsigned int address, void *unused)
>   {
> -	__print_symbol("  %s\n", address);
> +	printk("  %pS\n", (void *)address);
>   	return 0;
>   }
>   

