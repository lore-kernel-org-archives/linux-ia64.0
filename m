From: Grant Grundler <iod00d@hp.com>
Date: Thu, 15 May 2003 21:17:13 +0000
Subject: [Linux-ia64] Re: 64 Bits DMA Addresses for Alloc Consistent Interfaces.
Message-Id: <marc-linux-ia64-105590723705847@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705823@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705823@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, May 15, 2003 at 01:19:40PM -0700, David S. Miller wrote:
> Do not mix "must" parameters such as read/write protections with
> "it would be nice if" flag bits.

R/W "hints" is not required for ia64/parisc IOMMUs.
AFAIK, only swiotlb requires it and ZX1 IOMMU support has a one
performance optimization which makes use of R/W hint.

In short, "must" only applies to some subset of working platforms.

But in general I agree, hints should be useful to most architectures.
Having too many platform specific hints becomes hell for driver
writers.

grant

