From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 29 Apr 2019 15:59:04 +0000
Subject: Re: [PATCH 22/41] drivers: tty: serial: cpm_uart: fix logging calls
Message-Id: <a00ba23b-e73e-c964-a6d0-347cb605b8c8@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-23-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-23-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net



Le 27/04/2019 à 14:52, Enrico Weigelt, metux IT consult a écrit :
> Fix checkpatch warnings by using pr_err():
> 
>      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
>      #109: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:109:
>      +		printk(KERN_ERR
> 
>      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
>      #128: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:128:
>      +		printk(KERN_ERR
> 
>      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
>      +           printk(KERN_ERR
> 
>      WARNING: Prefer [subsystem eg: netdev]_err([subsystem]dev, ... then dev_err(dev, ... then pr_err(...  to printk(KERN_ERR ...
>      +           printk(KERN_ERR
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>

Reviewed-by: Christophe Leroy <christophe.leroy@c-s.fr>

But is that really worth doing those changes ?

If we want to do something useful, wouldn't it make more sense to 
introduce the use of dev_err() in order to identify the faulting device 
in the message ?

Christophe

> ---
>   drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c | 6 ++----
>   drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c | 6 ++----
>   2 files changed, 4 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
> index 56fc527..aed61e9 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm1.c
> @@ -71,8 +71,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
>   	dpmemsz = sizeof(cbd_t) * (pinfo->rx_nrfifos + pinfo->tx_nrfifos);
>   	dp_offset = cpm_dpalloc(dpmemsz, 8);
>   	if (IS_ERR_VALUE(dp_offset)) {
> -		printk(KERN_ERR
> -		       "cpm_uart_cpm1.c: could not allocate buffer descriptors\n");
> +		pr_err("cpm_uart_cpm1.c: could not allocate buffer descriptors\n");
>   		return -ENOMEM;
>   	}
>   	dp_mem = cpm_dpram_addr(dp_offset);
> @@ -90,8 +89,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
>   
>   	if (mem_addr = NULL) {
>   		cpm_dpfree(dp_offset);
> -		printk(KERN_ERR
> -		       "cpm_uart_cpm1.c: could not allocate coherent memory\n");
> +		pr_err("cpm_uart_cpm1.c: could not allocate coherent memory\n");
>   		return -ENOMEM;
>   	}
>   
> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> index 40cfcf4..a0fccda 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> @@ -106,8 +106,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
>   	dpmemsz = sizeof(cbd_t) * (pinfo->rx_nrfifos + pinfo->tx_nrfifos);
>   	dp_offset = cpm_dpalloc(dpmemsz, 8);
>   	if (IS_ERR_VALUE(dp_offset)) {
> -		printk(KERN_ERR
> -		       "cpm_uart_cpm.c: could not allocate buffer descriptors\n");
> +		pr_err("cpm_uart_cpm.c: could not allocate buffer descriptors\n");
>   		return -ENOMEM;
>   	}
>   
> @@ -125,8 +124,7 @@ int cpm_uart_allocbuf(struct uart_cpm_port *pinfo, unsigned int is_con)
>   
>   	if (mem_addr = NULL) {
>   		cpm_dpfree(dp_offset);
> -		printk(KERN_ERR
> -		       "cpm_uart_cpm.c: could not allocate coherent memory\n");
> +		pr_err("cpm_uart_cpm.c: could not allocate coherent memory\n");
>   		return -ENOMEM;
>   	}
>   
> 
