From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 00:06:03 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705867@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 18:45:42 -0500

   Something else I do not understand .. in the PCI world, what does
   Physical Memory Address got to do with 32Bit Mapped DMA
   Bus Address?
   
Many platforms direct map, that is what I assumed was happening
here and causing the problems.

   I have not seen any of the drivers broken yet - e.g. qlXXX, acenic,
   tg3 etc.
   
It only works because these devices happen to allow >32-bit DMA
addresses for descriptors.  You will find eventually that many
comodity pieces of PCI-X hardware will opt to only support 32-bit
DMA addressing for descriptor tables and whatnot.

