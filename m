From: Pavel Machek <pavel@suse.cz>
Date: Mon, 17 Jun 2002 08:16:29 +0000
Subject: [Linux-ia64] Re: [ACPI] [PATCH] random ia64 acpi fixes
Message-Id: <marc-linux-ia64-105590701905684@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi!

> Won't build on ia64 without this change.

This one is wrong. You should create empty include/asm/save_state.h instead.

									Pavel
> 
> diff -urNX ../dontdiff linux-2418/drivers/acpi/system.c linux-acpi/drivers/acpi/system.c
> --- linux-2418/drivers/acpi/system.c	Wed Jun 12 09:08:54 2002
> +++ linux-acpi/drivers/acpi/system.c	Wed Jun 12 07:20:26 2002
> @@ -37,7 +37,9 @@
>  #include <linux/proc_fs.h>
>  #include <asm/uaccess.h>
>  #include <asm/acpi.h>
> +#ifdef __i386__
>  #include <asm/save_state.h>
> +#endif
>  #include "acpi_bus.h"
>  #include "acpi_drivers.h"
>  
> 
> -- 
> It's always legal to use Linux (TM) systems
> http://www.gnu.org/philosophy/why-free.html
> 
> _______________________________________________________________
> 
> Sponsored by:
> ThinkGeek at http://www.ThinkGeek.com/
> _______________________________________________
> Acpi-devel mailing list
> Acpi-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/acpi-devel

-- 
Philips Velo 1: 1"x4"x8", 300gram, 60, 12MB, 40bogomips, linux, mutt,
details at http://atrey.karlin.mff.cuni.cz/~pavel/velo/index.html.


