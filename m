From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 01:23:12 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705882@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Grant Grundler <iod00d@hp.com>
   Date: Thu, 15 May 2003 18:20:51 -0700
   
   BTW, adding consistent_dma_mask to struct pci_dev and a
   corresponding pci_set_consistent_dma_mask() is a good idea.
   I think it would simplify our SBA code a bit.
   
Great, I'm glad this is resolved. :-)

