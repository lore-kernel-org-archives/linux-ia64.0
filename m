From: Esben Haabendal <esben@haabendal.dk>
Date: Mon, 29 Apr 2019 07:06:44 +0000
Subject: Re: [PATCH 35/41] drivers: tty: serial: 8250: add mapsize to platform data
Message-Id: <87wojdxpbv.fsf@haabendal.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
        <1556369542-13247-36-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-36-git-send-email-info@metux.net> (Enrico
        Weigelt's message of "Sat, 27 Apr 2019 14:52:16 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

"Enrico Weigelt, metux IT consult" <info@metux.net> writes:

> Adding a mapsize field for the 8250 port platform data struct,
> so we can now set the resource size (eg. *1) and don't need
> funny runtime detections like serial8250_port_size() anymore.
>
> For now, serial8250_port_size() is called everytime we need
> the io resource size. That function checks which chip we
> actually have and returns the appropriate size. This approach
> is a bit clumpsy and not entirely easy to understand, and
> it's a violation of layers :p
>
> Obviously, that information cannot change after the driver init,
> so we can safely do that probing once on driver init and just
> use the stored value later.
>
> *1) arch/mips/alchemy/common/platform.c
>
> Signed-off-by: Enrico Weigelt <info@metux.net>
> ---
>  drivers/tty/serial/8250/8250_core.c | 1 +
>  include/linux/serial_8250.h         | 1 +
>  2 files changed, 2 insertions(+)
>
> diff --git a/drivers/tty/serial/8250/8250_core.c b/drivers/tty/serial/8250/8250_core.c
> index e441221..71a398b 100644
> --- a/drivers/tty/serial/8250/8250_core.c
> +++ b/drivers/tty/serial/8250/8250_core.c
> @@ -814,6 +814,7 @@ static int serial8250_probe(struct platform_device *dev)
>  		uart.port.iotype	= p->iotype;
>  		uart.port.flags		= p->flags;
>  		uart.port.mapbase	= p->mapbase;
> +		uart.port.mapsize	= p->mapsize;
>  		uart.port.hub6		= p->hub6;
>  		uart.port.private_data	= p->private_data;
>  		uart.port.type		= p->type;
> diff --git a/include/linux/serial_8250.h b/include/linux/serial_8250.h
> index 5a655ba..8b8183a 100644
> --- a/include/linux/serial_8250.h
> +++ b/include/linux/serial_8250.h
> @@ -22,6 +22,7 @@ struct plat_serial8250_port {
>  	unsigned long	iobase;		/* io base address */
>  	void __iomem	*membase;	/* ioremap cookie or NULL */
>  	resource_size_t	mapbase;	/* resource base */
> +	resource_size_t	mapsize;	/* resource size */
>  	unsigned int	irq;		/* interrupt number */
>  	unsigned long	irqflags;	/* request_irq flags */
>  	unsigned int	uartclk;	/* UART clock rate */

Or replace iobase, mapbase and mapsize with a struct resource value?

/Esben
