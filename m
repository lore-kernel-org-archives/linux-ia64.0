From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 29 Apr 2019 16:02:30 +0000
Subject: Re: [PATCH 20/41] drivers: tty: serial: cpm_uart: use dev_err()/dev_warn() instead of printk()
Message-Id: <7509c580-e7c6-7d22-b6a2-8356264f408e@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-21-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-21-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net



Le 27/04/2019 à 14:52, Enrico Weigelt, metux IT consult a écrit :
> Using dev_err()/dev_warn() instead of printk() for more consistent output.
> (prints device name, etc).
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>

Reviewed-by: Christophe Leroy <christophe.leroy@c-s.fr>

> ---
>   drivers/tty/serial/cpm_uart/cpm_uart_core.c | 6 +++---
>   drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c | 2 +-
>   2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
> index b929c7a..374b8bb 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
> @@ -265,7 +265,7 @@ static void cpm_uart_int_rx(struct uart_port *port)
>   		 * later, which will be the next rx-interrupt or a timeout
>   		 */
>   		if (tty_buffer_request_room(tport, i) < i) {
> -			printk(KERN_WARNING "No room in flip buffer\n");
> +			dev_warn(port->dev, "No room in flip buffer\n");
>   			return;
>   		}
>   
> @@ -1155,7 +1155,7 @@ static int cpm_uart_init_port(struct device_node *np,
>   	if (!pinfo->clk) {
>   		data = of_get_property(np, "fsl,cpm-brg", &len);
>   		if (!data || len != 4) {
> -			printk(KERN_ERR "CPM UART %pOFn has no/invalid "
> +			dev_err(port->dev, "CPM UART %pOFn has no/invalid "
>   			                "fsl,cpm-brg property.\n", np);
>   			return -EINVAL;
>   		}
> @@ -1164,7 +1164,7 @@ static int cpm_uart_init_port(struct device_node *np,
>   
>   	data = of_get_property(np, "fsl,cpm-command", &len);
>   	if (!data || len != 4) {
> -		printk(KERN_ERR "CPM UART %pOFn has no/invalid "
> +		dev_err(port->dev, "CPM UART %pOFn has no/invalid "
>   		                "fsl,cpm-command property.\n", np);
>   		return -EINVAL;
>   	}
> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> index 6a1cd03..ef1ae08 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> @@ -67,7 +67,7 @@ void __iomem *cpm_uart_map_pram(struct uart_cpm_port *port,
>   		return pram;
>   
>   	if (len != 2) {
> -		printk(KERN_WARNING "cpm_uart[%d]: device tree references "
> +		dev_warn(port->dev, "cpm_uart[%d]: device tree references "
>   			"SMC pram, using boot loader/wrapper pram mapping. "
>   			"Please fix your device tree to reference the pram "
>   			"base register instead.\n",
> 
