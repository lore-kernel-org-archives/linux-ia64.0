From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 18 Sep 2006 17:28:14 +0000
Subject: Re: [PATCH 2/6] Introduce CONFIG_ZONE_DMA
Message-Id: <Pine.LNX.4.64.0609181027440.19312@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
  <20060911222739.4849.79915.sendpatchset@schroedinger.engr.sgi.com>
 <20060918135559.GB15096@infradead.org> <1158588487.31364.3.camel@localhost>
In-Reply-To: <1158588487.31364.3.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Martin Bligh <mbligh@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, linux-arch@vger.kernel.org

On Mon, 18 Sep 2006, Martin Schwidefsky wrote:

> s390 needs ZONE_DMA for the memory area below 2GB. That is required for
> the control structure of channel based I/O. It is not ISA but
> conceptually related. Can we rename GENERIC_ISA_DMA into GENERIC_IO_DMA
> or something similar?

The patchset defines CONFIG_ZONE_DMA for s390 so you are fine.

