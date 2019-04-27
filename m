From: Greg KH <gregkh@linuxfoundation.org>
Date: Sat, 27 Apr 2019 13:30:50 +0000
Subject: Re: [PATCH 05/41] drivers: tty: serial: dz: use pr_info() instead of incomplete printk()
Message-Id: <20190427133050.GB11368@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1556369542-13247-1-git-send-email-info@metux.net>
 <1556369542-13247-6-git-send-email-info@metux.net>
In-Reply-To: <1556369542-13247-6-git-send-email-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Enrico Weigelt, metux IT consult" <info@metux.net>
Cc: linux-kernel@vger.kernel.org, andrew@aj.id.au, andriy.shevchenko@linux.intel.com, macro@linux-mips.org, vz@mleia.com, slemieux.tyco@gmail.com, khilman@baylibre.com, liviu.dudau@arm.com, sudeep.holla@arm.com, lorenzo.pieralisi@arm.com, davem@davemloft.net, jacmet@sunsite.dk, linux@prisktech.co.nz, matthias.bgg@gmail.com, linux-mips@vger.kernel.org, linux-serial@vger.kernel.org, linux-ia64@vger.kernel.org, linux-amlogic@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Sat, Apr 27, 2019 at 02:51:46PM +0200, Enrico Weigelt, metux IT consult wrote:
> Fix the checkpatch warning:
> 
>     WARNING: printk() should include KERN_<LEVEL> facility level
>     #934: FILE: dz.c:934:
>     +	printk("%s%s\n", dz_name, dz_version);
> 
> Signed-off-by: Enrico Weigelt <info@metux.net>
> ---
>  drivers/tty/serial/dz.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/tty/serial/dz.c b/drivers/tty/serial/dz.c
> index 559d076..e2670c4 100644
> --- a/drivers/tty/serial/dz.c
> +++ b/drivers/tty/serial/dz.c
> @@ -931,7 +931,7 @@ static int __init dz_init(void)
>  	if (IOASIC)
>  		return -ENXIO;
>  
> -	printk("%s%s\n", dz_name, dz_version);
> +	pr_info("%s%s\n", dz_name, dz_version);

Just drop this line, it's not needed and generally just noise.

thanks,

greg k-h
