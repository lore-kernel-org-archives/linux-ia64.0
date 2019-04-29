From: Esben Haabendal <esben@haabendal.dk>
Date: Mon, 29 Apr 2019 06:57:43 +0000
Subject: Re: [PATCH 40/41] drivers: tty: serial: helper for setting mmio range
Message-Id: <87muk9z4bc.fsf@haabendal.dk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
        <1556369542-13247-41-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-41-git-send-email-info@metux.net> (Enrico
        Weigelt's message of "Sat, 27 Apr 2019 14:52:21 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

"Enrico Weigelt, metux IT consult" <info@metux.net> writes:

> @@ -131,7 +133,8 @@ int __init hp300_setup_serial_console(void)
>  		pr_info("Serial console is HP DCA at select code %d\n", scode);
>  
>  		port.uartclk = HPDCA_BAUD_BASE * 16;
> -		port.mapbase = (pa + UART_OFFSET);
> +
> +		uart_memres_set_start_len(&port, (pa + UART_OFFSET));

Missing length argument here.

>  		port.membase = (char *)(port.mapbase + DIO_VIRADDRBASE);
>  		port.regshift = 1;
>  		port.irq = DIO_IPL(pa + DIO_VIRADDRBASE);

> diff --git a/drivers/tty/serial/xilinx_uartps.c b/drivers/tty/serial/xilinx_uartps.c
> index cf8ca66..895c90c 100644
> --- a/drivers/tty/serial/xilinx_uartps.c
> +++ b/drivers/tty/serial/xilinx_uartps.c
> @@ -1626,8 +1626,7 @@ static int cdns_uart_probe(struct platform_device *pdev)
>  	 * This function also registers this device with the tty layer
>  	 * and triggers invocation of the config_port() entry point.
>  	 */
> -	port->mapbase = res->start;
> -	port->mapsize = CDNS_UART_REGISTER_SPACE;
> +	uart_memres_set_start_len(res->start, CDNS_UART_REGISTER_SPACE);

Missing 1st (port) argument here.

>  	port->irq = irq;
>  	port->dev = &pdev->dev;
>  	port->uartclk = clk_get_rate(cdns_uart_data->uartclk);

> diff --git a/include/linux/serial_core.h b/include/linux/serial_core.h
> index 5fe2b03..d891c8d 100644
> --- a/include/linux/serial_core.h
> +++ b/include/linux/serial_core.h
> @@ -427,6 +427,46 @@ void uart_console_write(struct uart_port *port, const char *s,
>  int uart_match_port(struct uart_port *port1, struct uart_port *port2);
>  
>  /*
> + * set physical io range from struct resource
> + * if resource is NULL, clear the fields
> + * also set the iotype to UPIO_MEM
> + */
> +static inline void uart_memres_set_res(struct uart_port *port,
> +				       struct resource *res)
> +{
> +	if (!res) {
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

Hardcoding UPIO_MEM like does not work for drivers using other kind of
memory access, like UPIO_MEM16, UPIO_MEM32 and UPIO_MEM32BE.

Why not leave the control of iotype to drivers as before this patch?

> +}
> +
> +/*
> + * set physical io range by start address and length
> + * if resource is NULL, clear the fields
> + * also set the iotype to UPIO_MEM
> + */
> +static inline void uart_memres_set_start_len(struct uart_driver *uart,
> +					     resource_size_t start,
> +					     resource_size_t len)
> +{
> +	uart->mapbase = start;
> +	uart->mapsize = len;
> +	uart->iotype  = UPIO_MEM;

Same here, other iotype values must be possible.

> +}
> +
> +/*
>   * Power Management
>   */
>  int uart_suspend_port(struct uart_driver *reg, struct uart_port *port);

/Esben
