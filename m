From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 01 Oct 2014 13:32:39 +0000
Subject: Re: [RFC PATCH 10/16] mips: support poweroff through poweroff handler call chain
Message-Id: <20141001133238.GJ19854@linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
 <1412100056-15517-11-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-11-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Tue, Sep 30, 2014 at 11:00:50AM -0700, Guenter Roeck wrote:

> The kernel core now supports a poweroff handler call chain
> to remove power from the system. Call it if pm_power_off
> is set to NULL.
> 
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  arch/mips/kernel/reset.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/mips/kernel/reset.c b/arch/mips/kernel/reset.c
> index 07fc524..c3391d7 100644
> --- a/arch/mips/kernel/reset.c
> +++ b/arch/mips/kernel/reset.c
> @@ -41,4 +41,6 @@ void machine_power_off(void)
>  {
>  	if (pm_power_off)
>  		pm_power_off();
> +	else
> +		do_kernel_poweroff();

I'm happy with this as long as in a later version pm_power_off indeed
goes away.

  Ralf
