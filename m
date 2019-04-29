From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Mon, 29 Apr 2019 16:02:58 +0000
Subject: Re: [PATCH 21/41] drivers: tty: serial: cpm_uart: fix includes
Message-Id: <da473f1b-d6a5-f82a-5af3-d4dfaaabf947@c-s.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-22-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-22-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>, linux-kernel@vger.kernel.org
Cc: lorenzo.pieralisi@arm.com, linux-ia64@vger.kernel.org, linux-serial@vger.kernel.org, andrew@aj.id.au, gregkh@linuxfoundation.org, sudeep.holla@arm.com, liviu.dudau@arm.com, linux-mips@vger.kernel.org, vz@mleia.com, linux@prisktech.co.nz, sparclinux@vger.kernel.org, khilman@baylibre.com, macro@linux-mips.org, slemieux.tyco@gmail.com, matthias.bgg@gmail.com, jacmet@sunsite.dk, linux-amlogic@lists.infradead.org, andriy.shevchenko@linux.intel.com, linuxppc-dev@lists.ozlabs.org, davem@davemloft.net



Le 27/04/2019 à 14:52, Enrico Weigelt, metux IT consult a écrit :
> Fixing checkpatch warning:
> 
>      WARNING: Use #include <linux/io.h> instead of <asm/io.h>
>      #25: FILE: drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c:25:
>      +#include <asm/io.h>
> 
>      WARNING: Use #include <linux/io.h> instead of <asm/io.h>
>      +#include <asm/io.h>
> 
>      WARNING: Use #include <linux/delay.h> instead of <asm/delay.h>
>      +#include <asm/delay.h>
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>

Reviewed-by: Christophe Leroy <christophe.leroy@c-s.fr>

> ---
>   drivers/tty/serial/cpm_uart/cpm_uart_core.c | 4 ++--
>   drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c | 2 +-
>   2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_core.c b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
> index 374b8bb..c831d31 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_core.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_core.c
> @@ -33,10 +33,10 @@
>   #include <linux/gpio.h>
>   #include <linux/of_gpio.h>
>   #include <linux/clk.h>
> +#include <linux/io.h>
> +#include <linux/delay.h>
>   
> -#include <asm/io.h>
>   #include <asm/irq.h>
> -#include <asm/delay.h>
>   #include <asm/fs_pd.h>
>   #include <asm/udbg.h>
>   
> diff --git a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> index ef1ae08..40cfcf4 100644
> --- a/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> +++ b/drivers/tty/serial/cpm_uart/cpm_uart_cpm2.c
> @@ -21,8 +21,8 @@
>   #include <linux/device.h>
>   #include <linux/memblock.h>
>   #include <linux/dma-mapping.h>
> +#include <linux/io.h>
>   
> -#include <asm/io.h>
>   #include <asm/irq.h>
>   #include <asm/fs_pd.h>
>   #include <asm/prom.h>
> 
