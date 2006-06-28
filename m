From: Prarit Bhargava <prarit@redhat.com>
Date: Wed, 28 Jun 2006 10:50:51 +0000
Subject: Re: [PATCH] fix prom revision checks in SN kernel
Message-Id: <44A25F0B.80204@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606271946.MAA19328@google.engr.sgi.com>
In-Reply-To: <200606271946.MAA19328@google.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>
> Index: linux/drivers/pci/hotplug/sgi_hotplug.c
> =================================> --- linux.orig/drivers/pci/hotplug/sgi_hotplug.c	2006-04-11 00:33:26.000000000 -0500
> +++ linux/drivers/pci/hotplug/sgi_hotplug.c	2006-06-26 14:53:15.693480748 -0500
> @@ -553,7 +553,7 @@
>  	int rc;
>  	int registered = 0;
>  
> -	if (sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
> +	if (is_shub1() && sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {
>  		printk(KERN_ERR "%s: PROM version must be greater than 4.30\n",
>  		       __FUNCTION__);
>  		return -EPERM;
> -
This should probably go to pcihpd-discuss ... But, I recall changing 
this to use feature sets at some point.  I'm surprised it is still in 
the code.

Greg, I cannot recall where you queue your patches -- would you mind 
fwd'ing a link?

Thanks,

P.
>   
