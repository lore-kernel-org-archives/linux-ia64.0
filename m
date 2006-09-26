From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 26 Sep 2006 16:48:31 +0000
Subject: Re: __get_free_pages() problem on ia64
Message-Id: <20060926164831.GG5017@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1159283801.4407.16.camel@triumph>
In-Reply-To: <1159283801.4407.16.camel@triumph>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 26, 2006 at 08:46:40PM +0530, Adhiraj wrote:
> I found a strange thing on ia64 platform. When I allocate pages using
> __get_free_pages() with GFP_DMA, sometimes the physical addresses of
> allocated pages fall beyond 4G.
> 
> I am working on a device driver where the device does not support
> addresses above 4G and hence I have to implement bounce buffers. The

You should be using the services described in
Documentation/DMA-mapping.txt rather than allocating your own bounce
buffers.

> The dma mask for the driver is set to 64 bits using pci_set_dma_mask().

Well, that's one of your problems right there .... if your device can
only DMA up to 4GB then you should set it to DMA_32BIT_MASK.
