From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 00:59:23 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705879@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Colin Ngam <cngam@sgi.com>
   Date: Thu, 15 May 2003 19:36:55 -0500
   
   I do not believe it is within spec to perform DAC when the
   Upper 32bits are 0s.

That is an illogical requirement in that it means PCI-X mode is
illegal in the presence of such addresses.  It means that PCI-X
devices cannot work in x86 systems with <4GB of memory which is
obviously not true.

