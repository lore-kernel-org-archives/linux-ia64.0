From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Date: Mon, 09 Nov 2015 20:48:26 +0000
Subject: Re: [PATCH 1/9] drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c: use correct structure type nam
Message-Id: <1915769.aHlhsWqSsK@avalon>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr> <1406647011-8543-2-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1406647011-8543-2-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Julia Lawall <Julia.Lawall@lip6.fr>
Cc: Mauro Carvalho Chehab <m.chehab@samsung.com>, kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-media@vger.kernel.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hi Julia,

Thank you for the patch.

On Tuesday 29 July 2014 17:16:43 Julia Lawall wrote:
> From: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Correct typo in the name of the type given to sizeof.  Because it is the
> size of a pointer that is wanted, the typo has no impact on compilation or
> execution.
> 
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
> semantic patch used can be found in message 0 of this patch series.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> ---
>  drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c
> b/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c index
> cda8388..255590f 100644
> --- a/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c
> +++ b/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c
> @@ -227,7 +227,7 @@ static int vpfe_enable_clock(struct vpfe_device
> *vpfe_dev) return 0;
> 
>  	vpfe_dev->clks = kzalloc(vpfe_cfg->num_clocks *
> -				   sizeof(struct clock *), GFP_KERNEL);
> +				   sizeof(struct clk *), GFP_KERNEL);

I'd use sizeof(*vpfe_dev->clks) to avoid such issues.

Apart from that,

Acked-by: Laurent Pinchart <laurent.pinchart@ideasonboard.com>

I've applied the patch to my tree with the above change, there's no need to 
resubmit if you agree with the proposal.

>  	if (vpfe_dev->clks = NULL) {
>  		v4l2_err(vpfe_dev->pdev->driver, "Memory allocation failed\n");
>  		return -ENOMEM;

-- 
Regards,

Laurent Pinchart

