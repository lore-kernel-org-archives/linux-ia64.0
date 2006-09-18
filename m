From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 18 Sep 2006 17:30:58 +0000
Subject: Re: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
Message-Id: <Pine.LNX.4.64.0609181029150.19312@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
  <20060911222739.4849.79915.sendpatchset@schroedinger.engr.sgi.com>
 <20060918135559.GB15096@infradead.org> <1158591485.3461.13.camel@mulgrave.il.steeleye.com>
In-Reply-To: <1158591485.3461.13.camel@mulgrave.il.steeleye.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@steeleye.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, linux-arch@vger.kernel.org

On Mon, 18 Sep 2006, James Bottomley wrote:

> On Mon, 2006-09-18 at 14:55 +0100, Christoph Hellwig wrote:
> > Let's pass this on to linux-arch so that the arch maintainers can give input
> > whether they need ZONE_DMA or not.  If this just sneaks in unseen I'd bet
> > various architectures will just keept it around despite not needing it.
> 
> Right at the moment, parisc has no use for ZONE_DMA.  We basically set
> ZONE_DMA = ZONE_NORMAL.  I don't believe our 32 bit systems will ever
> need it.  On the 64 bit systems currently we insist on having an IOMMU
> for every transaction, so ZONE_DMA = ZONE_NORMAL still.  However, on
> the zx1 systems, I can see us eventually implementing IOMMU bypass and
> for that case, we might need ZONE_DMA (primarily for GFP_DMA32, I
> suppose, which we could do internally).

What does parisc do with GENERIC_ISA_DMA? I see

config GENERIC_ISA_DMA
        bool

No default and no explanation?

Can I drop this from parisc's Kconfig? Is GENERIC_ISA_DMA set or not?

