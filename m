From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 29 Apr 2019 15:56:15 +0000
Subject: Re: [PATCH 23/41] drivers: tty: serial: cpm_uart: fix styling issues
Message-Id: <df50792f-88bc-379a-d9e1-4f2dc1f4965a@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-24-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-24-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net



Le 27/04/2019 à 14:52, Enrico Weigelt, metux IT consult a écrit :
> Fix checkpatch errors:

What the main purpose of this change ?

If we apply this, any fix to stable will be a nightmare to backport. Is 
it really worth it ?

Anyway, a couple of comments in the patch below

[...]

> 
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>
> ---
>   drivers/tty/serial/cpm_uart/cpm_uart.h      | 10 +--
>   drivers/tty/serial/cpm_uart/cpm_uart_core.c | 95 ++++++++++++++++-------------
>   drivers/tty/serial/cpm_uart/cpm_uart_cpm1.h |  4 +-
>   drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c |  6 +-
>   4 files changed, 64 insertions(+), 51 deletions(-)

[...]

> 
> @@ -1048,9 +1058,10 @@ static void cpm_uart_early_write(struct uart_cpm_port *pinfo,
>   static int poll_wait_key(char *obuf, struct uart_cpm_port *pinfo)
>   {
>   	u_char		c, *cp;
> -	volatile cbd_t	*bdp;
>   	int		i;
>   
> +	volatile cbd_t	*bdp;
> +

This was likely a false positive from checkpatch. The formatting was 
good, and now it is wrong as it adds an unnecessary blank line.

>   	/* Get the address of the host memory buffer.
>   	 */
>   	bdp = pinfo->rx_cur;

[...]

> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> index a0fccda..154ac19 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> @@ -117,8 +117,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
>   	if (is_con) {
>   		mem_addr = kzalloc(memsz, GFP_NOWAIT);
>   		dma_addr = virt_to_bus(mem_addr);
> -	}
> -	else
> +	} else
>   		mem_addr = dma_alloc_coherent(pinfo->port.dev, memsz, &dma_addr,
>   					      GFP_KERNEL);

Checkpatch should have told you that in case first leg has braces, 
second leg must have braces too even if it's a single line.

Christophe


>   
> @@ -148,7 +147,8 @@ void cpm_uart_freebuf(struct uart_cpm_port *pinfo)
>   	dma_free_coherent(pinfo->port.dev, L1_CACHE_ALIGN(pinfo->rx_nrfifos *
>   							  pinfo->rx_fifosize) +
>   			  L1_CACHE_ALIGN(pinfo->tx_nrfifos *
> -					 pinfo->tx_fifosize), (void __force *)pinfo->mem_addr,
> +					 pinfo->tx_fifosize),
> +			  (void __force *)pinfo->mem_addr,
>   			  pinfo->dma_addr);
>   
>   	cpm_dpfree(pinfo->dp_addr);
> 
