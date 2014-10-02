From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 02 Oct 2014 09:45:40 +0000
Subject: Re: [Xen-devel] [RFC PATCH 14/16] x86/xen: support poweroff through poweroff handler call chain
Message-Id: <542D1EC4.10100@citrix.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
 <1412100056-15517-15-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-15-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On 30/09/14 19:00, Guenter Roeck wrote:
> The kernel core now supports a poweroff handler call chain
> to remove power from the system. Call it if pm_power_off
> is set to NULL.
> 
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: H. Peter Anvin <hpa@zytor.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  arch/x86/xen/enlighten.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/x86/xen/enlighten.c b/arch/x86/xen/enlighten.c
> index c0cb11f..645d00f 100644
> --- a/arch/x86/xen/enlighten.c
> +++ b/arch/x86/xen/enlighten.c
> @@ -1322,6 +1322,8 @@ static void xen_machine_power_off(void)
>  {
>  	if (pm_power_off)
>  		pm_power_off();
> +	else
> +		do_kernel_poweroff();

Why isn't this if (pm_power_off) check in do_kernel_poweroff()?

That way when you finally remove pm_power_off you need only update one
place.  A quick skim of the other archs suggest this would work for them
too.

David
