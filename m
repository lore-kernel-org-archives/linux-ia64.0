From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 12 Sep 2006 01:40:02 +0000
Subject: Re: [PATCH 3/6] Optional ZONE_DMA in the VM
Message-Id: <Pine.LNX.4.64.0609111839140.7652@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060911222729.4849.69497.sendpatchset@schroedinger.engr.sgi.com>
 <20060911222744.4849.26386.sendpatchset@schroedinger.engr.sgi.com>
 <450600C7.7090801@yahoo.com.au>
In-Reply-To: <450600C7.7090801@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@vger.kernel.org, Martin Bligh <mbligh@google.com>, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo@kvack.org>, Arjan van de Ven <arjan@infradead.org>, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 12 Sep 2006, Nick Piggin wrote:

> I can't see from your patches, but what happens if someone asks
> for a GFP_DMA page or dma slab allocation when there is no ZONE_DMA?

The page/slab allocator will simply ignore the flag and return 
ZONE_NORMAL memory. See gfp_zone().

