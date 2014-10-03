From: Catalin Marinas <catalin.marinas@arm.com>
Date: Fri, 03 Oct 2014 10:30:56 +0000
Subject: Re: [RFC PATCH 05/16] arm64: support poweroff through poweroff handler call chain
Message-Id: <20141003103056.GB14110@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
 <1412100056-15517-6-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-6-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Tue, Sep 30, 2014 at 07:00:45PM +0100, Guenter Roeck wrote:
> The kernel core now supports a poweroff handler call chain
> to remove power from the system. Call it if pm_power_off
> is set to NULL.
> 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  arch/arm64/kernel/process.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
> index 398ab05..cc0c63e 100644
> --- a/arch/arm64/kernel/process.c
> +++ b/arch/arm64/kernel/process.c
> @@ -157,6 +157,8 @@ void machine_power_off(void)
>  	smp_send_stop();
>  	if (pm_power_off)
>  		pm_power_off();
> +	else
> +		do_kernel_poweroff();

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

As others already stated, I think we should eventually remove
pm_power_off entirely.

Catalin
