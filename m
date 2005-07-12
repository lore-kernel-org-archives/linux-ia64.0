From: Linas Vepstas <linas@austin.ibm.com>
Date: Tue, 12 Jul 2005 19:51:20 +0000
Subject: Re: [PATCH 2.6.13-rc1 03/10] IOCHK interface for I/O error handling/detecting
Message-Id: <20050712195120.GE26607@austin.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB664E.1050003@jp.fujitsu.com>
In-Reply-To: <42CB664E.1050003@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>


Hi,

Sorry for the late response ... 

I'm reading the patch, and I'm wondering what about performance and
overhead.   Here's the code that concerns me:

On Wed, Jul 06, 2005 at 02:04:14PM +0900, Hidetoshi Seto was heard to remark:
> [This is 3 of 10 patches, "iochk-03-register.patch"]
> 
> - Implement ia64 version of basic codes:
>     iochk_clear, iochk_read, iochk_init, and iocookie
>
>  int iochk_read(iocookie *cookie)
>  {
> +	if (cookie->error || have_error(cookie->dev))
....
> +}
> +
> +static int have_error(struct pci_dev *dev)
> +{
> +	u16 status;
> +
> +	/* check status */
> +	switch (dev->hdr_type) {
> +	case PCI_HEADER_TYPE_NORMAL: /* 0 */
> +		pci_read_config_word(dev, PCI_STATUS, &status);
> +		break;
> +	case PCI_HEADER_TYPE_BRIDGE: /* 1 */
> +		pci_read_config_word(dev, PCI_SEC_STATUS, &status);
> +		break;
> +	}
> +
> +	if ( (status & PCI_STATUS_REC_TARGET_ABORT)
> +		|| (status & PCI_STATUS_REC_MASTER_ABORT)
> +		|| (status & PCI_STATUS_DETECTED_PARITY) )
> +		return 1;
> 
>  	return 0;
>  }


Are you assuming that a device driver will use an iochk_read() for
every DMA operation? for every MMIO to the card?  

For high performance devices, it seems to me that this will cause
a rather large performance burden, especially if its envisioned that
all architectures will do something similar.

My concern is that (at least on ppc64) the call pci_read_config_word()
requires a call into "firmware" aka "BIOS", which takes thousands upon
thousands of cpu cycles.  There are hundreds of cycles of gratuitous
crud just to get into the firmware, and then lord-knows-what the
firmware does while its in there; probably doing all sorts of crazy
math to compute bus addresses and other arcane things.  I would imagine
that most architectures, includig ia64, are similar.

Thus, one wouldn't want to perform an iochk_read() in this way unless
one was already pretty sure that an error had already occured ... 

Am I misunderstanding something?

--linas

