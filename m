From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 23:27:33 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705855@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Thu, 15 May 2003 13:24:12 -0700
   
   How about this: drivers that support PCI-X cards are required to
   program the full 64 bits of a pci_alloc_consistent DMA address, the
   top 32 bits of which can be zero for most platforms.

How about this: you put the device attributes where they belong,
in the device struct.

