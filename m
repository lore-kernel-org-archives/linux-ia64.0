From: "David S. Miller" <davem@redhat.com>
Date: Fri, 16 May 2003 00:31:42 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705873@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Jesse Barnes <jbarnes@sgi.com>
   Date: Thu, 15 May 2003 17:29:05 -0700
   
   Also, are you saying that tg3 doesn't support all 64 bits of the DMA
   address?  If so, I'm not sure how it's working on our platform either,
   unless we're forcing it into PCI mode; I'll have to check.

I believe tg3 does, but some cost-sensitive PCI-X devices might decide
not to.

