From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Sun, 28 Apr 2019 15:39:05 +0000
Subject: Re: [PATCH 40/41] drivers: tty: serial: helper for setting mmio range
Message-Id: <20190428153905.GR9224@smile.fi.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-41-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-41-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Sat, Apr 27, 2019 at 02:52:21PM +0200, Enrico Weigelt, metux IT consult wrote:
> Introduce a little helpers for settings the mmio range from an
> struct resource or start/len parameters with less code.
> (also setting iotype to UPIO_MEM)
> 
> Also converting drivers to use these new helpers as well as
> fetching mapsize field instead of using hardcoded values.
> (the runtime overhead of that should be negligible)
> 
> The idea is moving to a consistent scheme, so later common
> calls like request+ioremap combination can be done by generic
> helpers.

> --- a/drivers/tty/serial/8250/8250_exar.c
> +++ b/drivers/tty/serial/8250/8250_exar.c
> @@ -134,8 +134,10 @@ static int default_setup(struct exar8250 *priv, struct pci_dev *pcidev,
>  	const struct exar8250_board *board = priv->board;
>  	unsigned int bar = 0;
>  
> -	port->port.iotype = UPIO_MEM;
> -	port->port.mapbase = pci_resource_start(pcidev, bar) + offset;
> +	uart_memres_set_start_len(&port->port,
> +				  pci_resource_start(pcidev, bar) + offset,
> +				  pci_resource_len(pcidev, bar));
> +

I don't see how it's better.
Moreover, the size argument seems wrong here.

> +		uart_memres_set_start_len(
> +			&port,
> +			FRODO_BASE + FRODO_APCI_OFFSET(1), 0);

Please, avoid such splitting, first parameter is quite fit above line.

>  		port.uartclk = HPDCA_BAUD_BASE * 16;
> -		port.mapbase = (pa + UART_OFFSET);
> +
> +		uart_memres_set_start_len(&port, (pa + UART_OFFSET));
>  		port.membase = (char *)(port.mapbase + DIO_VIRADDRBASE);
>  		port.regshift = 1;
>  		port.irq = DIO_IPL(pa + DIO_VIRADDRBASE);

Here...

>  	uart.port.flags = UPF_SKIP_TEST | UPF_SHARE_IRQ | UPF_BOOT_AUTOCONF;
>  	uart.port.irq = d->ipl;
>  	uart.port.uartclk = HPDCA_BAUD_BASE * 16;
> -	uart.port.mapbase = (d->resource.start + UART_OFFSET);
> +	uart_memres_set_start_len(&uart.port,
> +				  (d->resource.start + UART_OFFSET),
> +				  resource_size(&d->resource));
>  	uart.port.membase = (char *)(uart.port.mapbase + DIO_VIRADDRBASE);
>  	uart.port.regshift = 1;
>  	uart.port.dev = &d->dev;

...and here, and maybe in other places you split the assignments to the members
in two part. Better to call your function before or after these blocks of
assignments.

> -			uport->mapsize	= ZS_CHAN_IO_SIZE;
> -			uport->mapbase	= dec_kn_slot_base +
> -					  zs_parms.scc[chip] +
> -					  (side ^ ZS_CHAN_B) * ZS_CHAN_IO_SIZE;
> +
> +			uart_memres_set_start_len(dec_kn_slot_base +
> +						    zs_parms.scc[chip] +
> +						    (side ^ ZS_CHAN_B) *
> +							ZS_CHAN_IO_SIZE,
> +						  ZS_CHAN_IO_SIZE);

This looks hard to read. Think of temporary variables and better formatting
style.

>  /*
> + * set physical io range from struct resource
> + * if resource is NULL, clear the fields
> + * also set the iotype to UPIO_MEM

Something wrong with punctuation and style. Please, use proper casing and
sentences split.

> + */

Shouldn't be kernel-doc formatted?

> +static inline void uart_memres_set_res(struct uart_port *port,

Perhaps better name can be found.
Especially taking into account that it handles IO / MMIO here.

> +				       struct resource *res)
> +{
> +	if (!res) {

It should return an error in such case.

> +		port->mapsize = 0;
> +		port->mapbase = 0;
> +		port->iobase = 0;
> +		return;
> +	}
> +
> +	if (resource_type(res) = IORESOURCE_IO) {
> +		port->iotype = UPIO_PORT;
> +		port->iobase = resource->start;
> +		return;
> +	}
> +
> +	uart->mapbase = res->start;
> +	uart->mapsize = resource_size(res);

> +	uart->iotype  = UPIO_MEM;

Only one type? Why type is even set here?

> +}
> +
> +/*
> + * set physical io range by start address and length
> + * if resource is NULL, clear the fields
> + * also set the iotype to UPIO_MEM

Should be fixed as told above.

> + */

> +static inline void uart_memres_set_start_len(struct uart_driver *uart,
> +					     resource_size_t start,
> +					     resource_size_t len)

The comment doesn't tell why this is needed when we have one for struct
resource.

> +{
> +	uart->mapbase = start;
> +	uart->mapsize = len;

> +	uart->iotype  = UPIO_MEM;

Only one type?

> +}
> +
> +/*

-- 
With Best Regards,
Andy Shevchenko

