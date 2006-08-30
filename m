From: Hirokazu Takata <takata@linux-m32r.org>
Date: Wed, 30 Aug 2006 13:03:40 +0000
Subject: Re: [CFT:PATCH] Removing possible wrong asm/serial.h inclusions
Message-Id: <swf8xl61ikz.wl%takata.hirokazu@renesas.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060828085244.GA13544@flint.arm.linux.org.uk>
In-Reply-To: <20060828085244.GA13544@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-embedded@ozlabs.org, paulkf@microgate.com, takata@linux-m32r.org, linux-kernel@vger.kernel.org

From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: [CFT:PATCH] Removing possible wrong asm/serial.h inclusions
Date: Mon, 28 Aug 2006 09:52:44 +0100
> diff --git a/drivers/serial/m32r_sio.c b/drivers/serial/m32r_sio.c
> --- a/drivers/serial/m32r_sio.c
> +++ b/drivers/serial/m32r_sio.c
> @@ -76,17 +76,16 @@
>   */
>  #define is_real_interrupt(irq)	((irq) != 0)
>  
> -#include <asm/serial.h>
> +#define BASE_BAUD	115200
>  
>  /* Standard COM flags */
>  #define STD_COM_FLAGS (UPF_BOOT_AUTOCONF | UPF_SKIP_TEST)
>  
>  /*
>   * SERIAL_PORT_DFNS tells us about built-in ports that have no
>   * standard enumeration mechanism.   Platforms that can find all
>   * serial ports via mechanisms like ACPI or PCI need not supply it.
>   */
> -#undef SERIAL_PORT_DFNS
>  #if defined(CONFIG_PLAT_USRV)
>  
>  #define SERIAL_PORT_DFNS						\
> @@ -109,7 +108,7 @@
>  #endif /* !CONFIG_PLAT_USRV */
>  
>  static struct old_serial_port old_serial_port[] = {
> -	SERIAL_PORT_DFNS	/* defined in asm/serial.h */
> +	SERIAL_PORT_DFNS
>  };
>  
>  #define UART_NR	ARRAY_SIZE(old_serial_port)
> 

Acked-by: Hirokazu Takata <takata@linux-m32r.org>

Thank you.

-- Takata
