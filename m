From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 20:07:39 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705843@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 08:17:58 -0500
   
   Anyway, to make a long story short, we like to "extend" these
   interfaces to return DMA addresses of 64 bits if and when the
   driver has the full capabality to support DAC - via it's
   DMA mask capability setting.

All devices I am aware of do not support 64-bit addresses for their
descriptors, only 32-bit.

There is a huge difference between using a "64-bit address" and
requiring to generate a DAC cycle, the latter of which is
probably what you need and that is independant of what kind of
address pci_alloc_consistent() is giving you.


