From: Patrick Gefre <pfg@sgi.com>
Date: Wed, 04 Feb 2004 19:10:46 +0000
Subject: Re: PCI question
Message-Id: <402143B6.1040205@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
In-Reply-To: <200402032235.i13MZQXl018906@fsgi900.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Grant Grundler wrote:

>On Wed, Feb 04, 2004 at 11:04:42AM -0600, Patrick Gefre wrote:
>  
>
>>I think the 2.4 definition will be fine - at least for now. Was there a 
>>reason it was changed in 2.6 ?
>>    
>>
>
>Because no one was using it?
>
>Pat,
>two (three?) people have asked you to state what you want to add.
>Can you state the basic problem additional data fields would solve?
>
>It might be easier to just add those fields directly to pci_controller
>instead of messing with platform_data.
>
>grant
>  
>
We keep track of several things that are specific to our system:

struct sn_device_sysdata {
        vertex_hdl_t            vhdl;
        pciio_provider_t        *pci_provider;
        pciio_intr_t            intr_handle;
        struct sn_flush_device_list *dma_flush_list;
        pciio_piomap_t          pio_map[PCI_ROM_RESOURCE];
};

The platform_data element is what we use in 2.4 and seems like the way 
to go for 2.6.

-- Pat

