From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Wed, 01 May 2019 02:29:36 +0000
Subject: Re: [PATCH 06/41] drivers: tty: serial: sb1250-duart: use dev_err() instead of printk()
Message-Id: <alpine.LFD.2.21.1905010257020.30973@eddie.linux-mips.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net> <1556369542-13247-7-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-7-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, "David S. Miller" <davem@davemloft.net>, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Sat, 27 Apr 2019, Enrico Weigelt, metux IT consult wrote:

> diff --git a/drivers/tty/serial/sb1250-duart.c b/drivers/tty/serial/sb1250-duart.c
> index 329aced..655961c 100644
> --- a/drivers/tty/serial/sb1250-duart.c
> +++ b/drivers/tty/serial/sb1250-duart.c
> @@ -663,7 +663,6 @@ static void sbd_release_port(struct uart_port *uport)
>  
>  static int sbd_map_port(struct uart_port *uport)
>  {
> -	const char *err = KERN_ERR "sbd: Cannot map MMIO\n";
>  	struct sbd_port *sport = to_sport(uport);
>  	struct sbd_duart *duart = sport->duart;
>  
> @@ -671,7 +670,7 @@ static int sbd_map_port(struct uart_port *uport)
>  		uport->membase = ioremap_nocache(uport->mapbase,
>  						 DUART_CHANREG_SPACING);
>  	if (!uport->membase) {
> -		printk(err);
> +		dev_err(uport->dev, "Cannot map MMIO (base)\n");
>  		return -ENOMEM;
>  	}
>  
> @@ -679,7 +678,7 @@ static int sbd_map_port(struct uart_port *uport)
>  		sport->memctrl = ioremap_nocache(duart->mapctrl,
>  						 DUART_CHANREG_SPACING);
>  	if (!sport->memctrl) {
> -		printk(err);
> +		dev_err(uport->dev, "Cannot map MMIO (ctrl)\n");
>  		iounmap(uport->membase);
>  		uport->membase = NULL;
>  		return -ENOMEM;

 Hmm, what's the point to have separate messages, which consume extra 
memory, for a hardly if at all possible error condition?

  Maciej
