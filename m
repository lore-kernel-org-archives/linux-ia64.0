From: Jens Axboe <axboe@suse.de>
Date: Mon, 22 Mar 2004 18:56:59 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <20040322185658.GS1481@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 22 2004, Bjorn Helgaas wrote:
> On Monday 22 March 2004 2:36 am, Andrew Morton wrote:
> > This adds the necessary stubs for ia64 and builds OK with my config, but it
> > needs a double-check.
> 
> In addition, I needed the following patch to build the ide-cd driver
> because the ia64 generic target makes "dma_error" a #define.
> 
> diff -u -ur 2.6-mm/drivers/ide/ide-cd.c 2.6/drivers/ide/ide-cd.c
> --- 2.6-mm/drivers/ide/ide-cd.c	2004-03-22 11:26:42.000000000 -0700
> +++ 2.6/drivers/ide/ide-cd.c	2004-03-22 10:17:00.000000000 -0700
> @@ -1044,7 +1044,7 @@
>  	int ireason, len, sectors_to_transfer, nskip;
>  	struct cdrom_info *info = drive->driver_data;
>  	u8 lowcyl = 0, highcyl = 0;
> -	int dma = info->dma, dma_error = 0;
> +	int dma = info->dma, dma_err = 0;

This is really silly imho, make ia64 generic target cut down on it's
name space polution instead then.

-- 
Jens Axboe

