From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 04 Feb 2004 19:50:44 +0000
Subject: Re: PCI question
Message-Id: <200402041250.44802.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 04 February 2004 12:10 pm, Patrick Gefre wrote:
> We keep track of several things that are specific to our system:
> 
> struct sn_device_sysdata {
>         vertex_hdl_t            vhdl;
>         pciio_provider_t        *pci_provider;
>         pciio_intr_t            intr_handle;
>         struct sn_flush_device_list *dma_flush_list;
>         pciio_piomap_t          pio_map[PCI_ROM_RESOURCE];
> };
> 
> The platform_data element is what we use in 2.4 and seems like the way 
> to go for 2.6.

If you make yourself a macro to go from a pci_dev to sn_device_sysdata,
you can make your code independent of where the SGI-specific stuff
actually lives.  Probably you already do that.

