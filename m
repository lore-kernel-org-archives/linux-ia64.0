From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 23:11:04 +0000
Subject: Re: [PATCH 24/28] ia64/xen: time paravirtualization
Message-Id: <47BE0508.7080203@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yamahata@valinux.co.jp wrote:
> diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
> index 17fda52..1bb0362 100644
> --- a/arch/ia64/kernel/time.c
> +++ b/arch/ia64/kernel/time.c
> @@ -29,6 +29,14 @@
>  #include <asm/sections.h>
>  #include <asm/system.h>
>  
> +#include <asm/xen/hypervisor.h>
> +#ifdef CONFIG_XEN
> +#include <linux/kernel_stat.h>
> +#include <linux/posix-timers.h>
> +#include <xen/interface/vcpu.h>
> +#include <asm/percpu.h>
> +#endif
> +

ia64 doesn't use clocksources yet?  Couldn't you share a lot of this 
with the 32-bit Xen time code (esp stolen time accounting)?

    J
