From: Greg KH <gregkh@linuxfoundation.org>
Date: Sat, 27 Apr 2019 13:32:15 +0000
Subject: Re: [PATCH 10/41] drivers: tty: serial: sb1250-duart: fix missing parentheses
Message-Id: <20190427133215.GD11368@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-11-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-11-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Sat, Apr 27, 2019 at 02:51:51PM +0200, Enrico Weigelt, metux IT consult wrote:
> Fix checkpatch warning:
> 
>     ERROR: Macros with complex values should be enclosed in parentheses
>     #911: FILE: drivers/tty/serial/sb1250-duart.c:911:
>     +#define SERIAL_SB1250_DUART_CONSOLE	&sbd_console
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>
> ---
>  drivers/tty/serial/sb1250-duart.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/tty/serial/sb1250-duart.c b/drivers/tty/serial/sb1250-duart.c
> index 1184226..ec74f09 100644
> --- a/drivers/tty/serial/sb1250-duart.c
> +++ b/drivers/tty/serial/sb1250-duart.c
> @@ -908,7 +908,7 @@ static int __init sbd_serial_console_init(void)
>  
>  console_initcall(sbd_serial_console_init);
>  
> -#define SERIAL_SB1250_DUART_CONSOLE	&sbd_console
> +#define SERIAL_SB1250_DUART_CONSOLE	(&sbd_console)

No, that's foolish.

checkpatch is a hint, it's not always right.

Also, checkpatch cleanups for really old drivers is not generally a good
idea, especially if you do not have the hardware for them.  Please don't
cause unneeded churn for this type of thing in this subsystem, unless
you have the hardware.

thanks,

greg k-h
