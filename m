From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 02 Mar 2005 04:47:25 +0000
Subject: Re: [PATCH 2.6.11-rc3 1/1] altix: Device driver support for the CX port of SGI's TIO chip
Message-Id: <20050302044725.GA10568@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050228235822.16768.33715.29715@attica.americas.sgi.com>
In-Reply-To: <20050228235822.16768.33715.29715@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

(care to split this into a two-patch series for the next submission,
one for tiocx, one for mbcs?)

> +obj-$(CONFIG_SGI_TIOCX)		+= tiocx.o

this one should really be in arch/ia64/sn/

> +#endif
> +int mbcs_major = 0;
> +
> +extern struct bus_type tiocx_bus_type;

externs in .c files are a big no-go in Linux.  But you
shouldn't need this variable anyway.

> +static void getDma_init(struct getDma_soft_s *pGetDma)

please avoid oddly-Caps names and _s prefix for structures,
should more look like

static void mbcs_getdma_init(struct getdma *gd)

> +{
> +	/* setup engine parameters */
> +	pGetDma->hostAddr = 0;
> +	pGetDma->localAddr = 0;
> +	pGetDma->bytes = 0;
> +	pGetDma->DoneAmoEnable = 0;
> +	pGetDma->DoneIntEnable = 1;
> +	pGetDma->peerIO = 0;
> +	pGetDma->amoHostDest = 0;
> +	pGetDma->amoModType = 0;
> +	pGetDma->intrHostDest = 0;
> +	pGetDma->intrVector = 0;

why not memset the whole structure?

> +static ssize_t
> +do_mbcs_sram_dmaread(struct mbcs_soft_s *soft, uint64_t hostAddr,
> +		     size_t len, loff_t * off)
> +{
> +	int rv = 0;
> +
> +	soft->getDma.hostAddr = hostAddr;
> +	soft->getDma.localAddr = *off;
> +	soft->getDma.bytes = len;
> +
> +	if (getDma_start(soft) < 0) {
> +		DBG(KERN_ALERT "mbcs_strategy: getDma_start failed\n");
> +		return -EAGAIN;
> +	}
> +
> +	interruptible_sleep_on(&soft->dmaread_queue);

never use sleep_on or its variants.  Use wait_event instead with a proper
condition to wait for.  (Also in various other places in the driver)

> +{
> +	struct mbcs_callback_arg cba;
> +
> +	if (ip = NULL || fp = NULL)
> +		return -EINVAL;

can't ever happen.

> 
> +
> +	cba.minor = iminor(ip);
> +
> +	cba.cx_dev = NULL;
> +	bus_for_each_dev(&tiocx_bus_type, NULL, &cba, mbcs_find_device);

urgg, no.  Please keep a local doubly-linked list of devices you
got ->porbe called for and search that one.

> +static int mbcs_probe(struct cx_dev *dev, const struct cx_device_id *id)
> +{
> +	struct mbcs_soft_s *soft;
> +
> +	dev->soft = NULL;
> +
> +	soft = (struct mbcs_soft_s *)kcalloc(1,
> +					     sizeof(struct mbcs_soft_s),
> +					     GFP_KERNEL);

no need to cast the kcalloc return value


the whole mbcs driver looks rather odd, what is it trying to do?
