From: "David S. Miller" <davem@redhat.com>
Date: Thu, 15 May 2003 20:19:40 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705845@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Grant Grundler <iod00d@hp.com>
   Date: Thu, 15 May 2003 12:06:22 -0700
   
   This would help chipset specific DMA support pick "optimal"
   settings for DMA operations.

I vehemently will fight any such rediculious ideas.

The whole concept behind these portable DMA apis is to avoid
platforms specific junk, it all must be generic and apply to
everyone.

   I was thinking of redefining "direction" parameter to be "hints".
   It would continue to support Read or Write "hint" but then use
   upper bits as flags for other things (don't want to completely
   spoil my talk).

Do not mix "must" parameters such as read/write protections with
"it would be nice if" flag bits.


