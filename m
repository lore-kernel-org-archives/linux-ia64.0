From: James Bottomley <James.Bottomley@SteelEye.com>
Date: Mon, 18 Sep 2006 14:58:05 +0000
Subject: Re: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
Message-Id: <1158591485.3461.13.camel@mulgrave.il.steeleye.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
	 <20060911222739.4849.79915.sendpatchset@schroedinger.engr.sgi.com>
	 <20060918135559.GB15096@infradead.org>
In-Reply-To: <20060918135559.GB15096@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, linux-arch@vger.kernel.org

On Mon, 2006-09-18 at 14:55 +0100, Christoph Hellwig wrote:
> Let's pass this on to linux-arch so that the arch maintainers can give input
> whether they need ZONE_DMA or not.  If this just sneaks in unseen I'd bet
> various architectures will just keept it around despite not needing it.

Right at the moment, parisc has no use for ZONE_DMA.  We basically set
ZONE_DMA = ZONE_NORMAL.  I don't believe our 32 bit systems will ever
need it.  On the 64 bit systems currently we insist on having an IOMMU
for every transaction, so ZONE_DMA = ZONE_NORMAL still.  However, on
the zx1 systems, I can see us eventually implementing IOMMU bypass and
for that case, we might need ZONE_DMA (primarily for GFP_DMA32, I
suppose, which we could do internally).

James


