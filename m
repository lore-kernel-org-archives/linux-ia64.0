From: Grant Grundler <iod00d@hp.com>
Date: Thu, 19 Jun 2003 21:47:16 +0000
Subject: Re: SCSI ERRORS triggered by BIO_VMERGE_BOUNDARY
Message-Id: <marc-linux-ia64-105605932519964@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105604433402604@msgid-missing>
In-Reply-To: <marc-linux-ia64-105604433402604@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 19, 2003 at 10:36:34AM -0700, David Mosberger wrote:
> My suspicion is that something is wrong in the sba_iommu.c code
> with respect to block merging.

That's probably a good place to start. The DMA block merging code
is the most fragile peice in sba_iommu.c. I still have fixes from
Peter Chubb on fixing some of that in the partial rewrite I started
last year. I might have some time short-term to revisit that a bit.

grant
