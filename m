From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 16 Jun 2004 17:34:24 +0000
Subject: Re: [PATCH 4/4] SGI Altix cross partition functionality
Message-Id: <20040616173424.GA16166@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163746.GD27891@sgi.com>
In-Reply-To: <20040616163746.GD27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +config IA64_SGI_SN_XPNET
> +	tristate "SGI DMA pseudo-ethernet driver"
> +	depends on IA64_SGI_SN_XPC
> +	default m if IA64_SGI_SN_XPC

please don't overuse the default statement, just add it to the SN2 defconfig.

> +	help
> +	  An SGI machine can be divided into multiple Single System
> +	  Images which act independently of each other and have
> +	  hardware based memory protection from the others.  Enabling
> +	  this feature will produce a network adapter that can be
> +	  used to communicate directly between SSIs.
> +
>  config IA64_SGI_SN_SIM
>  	bool "SGI Medusa Simulator Support"
>  	depends on IA64_SGI_SN2
> Index: linux/arch/ia64/sn/kernel/Makefile
> =================================> --- linux.orig/arch/ia64/sn/kernel/Makefile	2004-06-14 13:01:24.000000000 -0500
> +++ linux/arch/ia64/sn/kernel/Makefile	2004-06-14 14:24:53.000000000 -0500
> @@ -18,3 +18,5 @@
>  CFLAGS_xpc_kdb.o += -I $(TOPDIR)/arch/$(ARCH)/kdb
>  CFLAGS_xpc_channel.o += -I $(TOPDIR)/arch/$(ARCH)/kdb
>  CFLAGS_xpc_partition.o += -I $(TOPDIR)/arch/$(ARCH)/kdb
> +obj-$(CONFIG_IA64_SGI_SN_XPNET)	+= xpnet.o
> +CFLAGS_xpnet.o += -I $(TOPDIR)/arch/$(ARCH)/kdb

and that CFLAGS gunk needs to go away.  a) kdb isn't in mainline, b) kdb 4.4 doesn't need it

> +/* once Linux 2.4 is no longer supported, eliminate these gyrations */
> +
> +#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0) && \
> +    LINUX_VERSION_CODE <  KERNEL_VERSION(2,5,0)

Please don't keep them around in the main driver for 2.6.  Add a small kcompat.h
that you can add to the 2.4 variant.

> +#else /* LINUX_VERSION_CODE = Linux 2.4 */
> +
> +#define EXPORT_NO_SYMBOLS

This is wrong and doesn't do anything on 2.6 anymore.

> +
> +#endif /* LINUX_VERSION_CODE = Linux 2.4 */

> + * Define the XPNET debug sets and other items used with DPRINTK.
> + */
> +#define XPNET_DBG_CONSOLE	0x0000000000000001
> +#define XPNET_DBG_ERROR		0x0000000000000002
> +
> +#define XPNET_DBG_SETUP		0x0000000000000004
> +
> +#define XPNET_DBG_SEND		0x0000000000000010
> +#define XPNET_DBG_RECV		0x0000000000000020
> +
> +#define XPNET_DBG_SENDV		0x0000000000000100
> +#define XPNET_DBG_RECVV		0x0000000000000200
> +
> +#define XPNET_DBG_SENDVV	0x0000000000001000
> +#define XPNET_DBG_RECVVV	0x0000000000002000

Please use normal netif_msg_ levels.

> +DECLARE_DPRINTK(xpnet, 1000, XPNET_DBG_DEFCAPTURE_SETS,
> +		XPNET_DBG_DEFCONSOLE_SETS, XPNET_DBG_SET_DESCRIPTION);

What the is this?

> +	DPRINTK(xpnet, XPNET_DBG_RECV,
> +		"received 0x%lx, %d, %d, %d\n", msg->buf_pa, msg->size,
> +		msg->leadin_ignore, msg->tailout_ignore);
> +
> +
> +	/* reserve an extra cache line */
> +	skb = dev_alloc_skb(msg->size + L1_CACHE_BYTES);
> +	if (!skb) {
> +		DPRINTK_ALWAYS(xpnet, (XPNET_DBG_RECV | XPNET_DBG_ERROR),
> +			KERN_ERR "XPNET: failed on dev_alloc_skb(%d)\n",
> +			msg->size + L1_CACHE_BYTES);

please use standard printk/dev_printk/dev_info/dev_dbg/etc.. helpers.

> +	XP_ASSERT(partid > 0 && partid < MAX_PARTITIONS);
> +	XP_ASSERT(channel = XPC_NET_CHANNEL);

please use BUG_ON

> +EXPORT_NO_SYMBOLS;

Another one, and still not better.

This driver probably also wants a review on netdev@oss.sgi.com

