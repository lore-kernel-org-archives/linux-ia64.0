From: Stefan Agner <stefan@agner.ch>
Date: Sun, 05 Apr 2015 23:09:06 +0000
Subject: Re: [PATCH V2] tty: serial: Add const to struct =?UTF-8?Q?uart=5Fops=20declarations?=
Message-Id: <d55b1a1240db66ae651cb99cd713694a@agner.ch>
List-Id: <linux-ia64.vger.kernel.org>
References: <1428169665.2775.53.camel@perches.com>
 <a938a0e86638588e5ccff85771fa3b95@agner.ch>
 <1428258294.2775.69.camel@perches.com>
In-Reply-To: <1428258294.2775.69.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-F5mvAk5X5gdBDgjK7y7TUQ@public.gmane.org, Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>, Timur Tabi <timur-N01EOCouUvQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pat Gefre <pfg-sJ/iWh9BUns@public.gmane.org>, Laxman Dewangan <ldewangan-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, "Maciej W. Rozycki" <macro-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, Daniel Walker <dwalker-zu3NM2574RrQT0dZR+AlfA@public.gmane.org>, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>, Sonic Zhang <sonic.zhang-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, Michal Simek <michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tobias Klauser <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux

On 2015-04-05 20:24, Joe Perches wrote:
> Still compiled only x86 and not cross-compiled or tested.

Cross-compiled with multi_v7_defconfig

> 
>  drivers/tty/serial/21285.c                  | 2 +-
>  drivers/tty/serial/altera_jtaguart.c        | 2 +-
>  drivers/tty/serial/altera_uart.c            | 2 +-
>  drivers/tty/serial/amba-pl010.c             | 2 +-
>  drivers/tty/serial/amba-pl011.c             | 2 +-
>  drivers/tty/serial/apbuart.c                | 2 +-
>  drivers/tty/serial/ar933x_uart.c            | 2 +-
>  drivers/tty/serial/arc_uart.c               | 2 +-
>  drivers/tty/serial/atmel_serial.c           | 2 +-
>  drivers/tty/serial/bcm63xx_uart.c           | 2 +-
>  drivers/tty/serial/bfin_sport_uart.c        | 2 +-
>  drivers/tty/serial/bfin_uart.c              | 2 +-
>  drivers/tty/serial/cpm_uart/cpm_uart_core.c | 2 +-
>  drivers/tty/serial/dz.c                     | 2 +-
>  drivers/tty/serial/efm32-uart.c             | 2 +-
>  drivers/tty/serial/fsl_lpuart.c             | 4 ++--

Tested that driver on actual hardware, looks fine.

>  drivers/tty/serial/icom.c                   | 2 +-
>  drivers/tty/serial/imx.c                    | 2 +-
>  drivers/tty/serial/ioc3_serial.c            | 2 +-
>  drivers/tty/serial/ioc4_serial.c            | 2 +-
>  drivers/tty/serial/ip22zilog.c              | 2 +-
>  drivers/tty/serial/jsm/jsm_tty.c            | 2 +-
>  drivers/tty/serial/lantiq.c                 | 2 +-
>  drivers/tty/serial/lpc32xx_hs.c             | 2 +-
>  drivers/tty/serial/m32r_sio.c               | 2 +-
>  drivers/tty/serial/max3100.c                | 2 +-
>  drivers/tty/serial/men_z135_uart.c          | 2 +-
>  drivers/tty/serial/meson_uart.c             | 2 +-
>  drivers/tty/serial/mpc52xx_uart.c           | 2 +-
>  drivers/tty/serial/mpsc.c                   | 2 +-
>  drivers/tty/serial/msm_serial.c             | 2 +-
>  drivers/tty/serial/mux.c                    | 2 +-
>  drivers/tty/serial/mxs-auart.c              | 2 +-
>  drivers/tty/serial/netx-serial.c            | 2 +-
>  drivers/tty/serial/nwpserial.c              | 2 +-
>  drivers/tty/serial/omap-serial.c            | 2 +-
>  drivers/tty/serial/pch_uart.c               | 2 +-
>  drivers/tty/serial/pmac_zilog.c             | 2 +-
>  drivers/tty/serial/pnx8xxx_uart.c           | 2 +-
>  drivers/tty/serial/pxa.c                    | 2 +-
>  drivers/tty/serial/sa1100.c                 | 2 +-
>  drivers/tty/serial/samsung.c                | 2 +-

This driver seems to alter the startup function on initialization:

  CC      drivers/video/of_display_timing.o
../drivers/tty/serial/samsung.c: In function 's3c24xx_serial_init_port':
../drivers/tty/serial/samsung.c:1702:3: error: assignment of member
'startup' in read-only object
   s3c24xx_serial_ops.startup = s3c64xx_serial_startup;
   ^

>  drivers/tty/serial/serial-tegra.c           | 2 +-
>  drivers/tty/serial/serial_ks8695.c          | 2 +-
>  drivers/tty/serial/serial_txx9.c            | 2 +-
>  drivers/tty/serial/sh-sci.c                 | 2 +-
>  drivers/tty/serial/sirfsoc_uart.c           | 2 +-
>  drivers/tty/serial/sn_console.c             | 2 +-
>  drivers/tty/serial/sprd_serial.c            | 2 +-
>  drivers/tty/serial/st-asc.c                 | 2 +-
>  drivers/tty/serial/sunhv.c                  | 2 +-
>  drivers/tty/serial/sunsab.c                 | 2 +-
>  drivers/tty/serial/sunsu.c                  | 2 +-
>  drivers/tty/serial/sunzilog.c               | 2 +-
>  drivers/tty/serial/timbuart.c               | 2 +-
>  drivers/tty/serial/uartlite.c               | 2 +-
>  drivers/tty/serial/ucc_uart.c               | 2 +-
>  drivers/tty/serial/vr41xx_siu.c             | 2 +-
>  drivers/tty/serial/vt8500_serial.c          | 2 +-
>  drivers/tty/serial/xilinx_uartps.c          | 2 +-
>  drivers/tty/serial/zs.c                     | 2 +-
>  61 files changed, 62 insertions(+), 62 deletions(-)

That is the only thing which popped up with multi_v7_defconfig.

--
Stefan
