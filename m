From: Jes Sorensen <jes@sgi.com>
Date: Thu, 23 Aug 2007 08:45:27 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <46CD4927.2080505@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com>	 <200708220903.23702.jbarnes@virtuousgeek.org>	 <1187801095.3410.49.camel@localhost.localdomain>	 <200708220951.05101.jbarnes@virtuousgeek.org>	 <1187802272.3410.58.camel@localhost.localdomain> <46CC6C4B.1030202@sgi.com> <1187806205.3410.66.camel@localhost.localdomain>
In-Reply-To: <1187806205.3410.66.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, akepner@sgi.com, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

James Bottomley wrote:
> Hmm, didn't see the email ... but I'm probably not cc'd on all the
> thread.  However ... it isn't that you couldn't do it ... it's that you
> don't want to do it because it's faster to violate the spec ... like all
> those nice ATA devices that lie about having a cache and then let you
> power down with uncommitted data still in it ... they work much faster
> for HDIO tests ... and who ever switches their box off?

James,

I didn't do it, I don't know who did it, but sure we can try and track
them down and line them up outside .....

Point is that this is how the chips were done and they are out there in
numbers. It makes things a *lot* faster to violate the spec in such a
system, yes it sucks, but thats how things are. It wouldn't be the first
time someone violated the PCI spec in their implementation and I am
pretty sure it won't be the last.

Cheers,
Jes
