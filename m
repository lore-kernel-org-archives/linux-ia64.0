From: Adhiraj <adhiraj@linsyssoft.com>
Date: Tue, 26 Sep 2006 15:28:40 +0000
Subject: __get_free_pages() problem on ia64
Message-Id: <1159283801.4407.16.camel@triumph>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi All,

I found a strange thing on ia64 platform. When I allocate pages using
__get_free_pages() with GFP_DMA, sometimes the physical addresses of
allocated pages fall beyond 4G.

I am working on a device driver where the device does not support
addresses above 4G and hence I have to implement bounce buffers. The
bounce buffer code works fine on other architectures. But since I get 
4G+ addresses on ia64, the code would not work. Any idea why should this
happen? And any workaround if I _NEED_ addresses below 4G. The machine
has 2G of physical memory.

The dma mask for the driver is set to 64 bits using pci_set_dma_mask().

Thanks in advance,
Adhiraj.

