From: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Date: Sat, 01 Nov 2014 10:16:37 +0000
Subject: Re: [PATCH 33/44] avr32: atngw100: Register with kernel poweroff handler
Message-Id: <20141101101637.GA5765@samfundet.no>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412659726-29957-1-git-send-email-linux@roeck-us.net>
 <1412659726-29957-34-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412659726-29957-34-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lguest-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m32r-ja-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, openipmi-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xen-devel-GuqFBffKawtpuQazS67q72D2FQJk+8+b@public.gmane.org, Haavard

Around Mon 06 Oct 2014 22:28:35 -0700 or thereabout, Guenter Roeck wrote:
> Register with kernel poweroff handler instead of setting pm_power_off
> directly.
> 
> Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
> Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Hans-Christian Egtvedt <egtvedt@samfundet.no>

> ---
>  arch/avr32/boards/atngw100/mrmt.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/avr32/boards/atngw100/mrmt.c b/arch/avr32/boards/atngw100/mrmt.c
> index 91146b4..54d0c27 100644
> --- a/arch/avr32/boards/atngw100/mrmt.c
> +++ b/arch/avr32/boards/atngw100/mrmt.c
> @@ -274,7 +274,7 @@ static int __init mrmt1_init(void)
>  {
>  	gpio_set_value( PIN_PWR_ON, 1 );	/* Ensure PWR_ON is enabled */
>  
> -	pm_power_off = mrmt_power_off;
> +	register_poweroff_handler_simple(mrmt_power_off, 128);
>  
>  	/* Setup USARTS (other than console) */
>  	at32_map_usart(2, 1, 0);	/* USART 2: /dev/ttyS1, RMT1:DB9M */
-- 
mvh
Hans-Christian Egtvedt
