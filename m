From: akepner@sgi.com
Date: Wed, 22 Aug 2007 18:44:24 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <20070822184424.GT5592@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <200708220951.05101.jbarnes@virtuousgeek.org> <1187802272.3410.58.camel@localhost.localdomain> <200708221017.11805.jbarnes@virtuousgeek.org> <1187806384.3410.70.camel@localhost.localdomain>
In-Reply-To: <1187806384.3410.70.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, Jes Sorensen <jes@sgi.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

On Wed, Aug 22, 2007 at 01:13:04PM -0500, James Bottomley wrote:
> ......
> OK ... I think this is definitely a PCI specific API ... and probably a
> generic one for requesting order flushes in devices that have negotiated
> relaxed ordering.  Do you want to start a new thread on linux-pci and cc
> me?
> 

I'll do this.

-- 
Arthur

