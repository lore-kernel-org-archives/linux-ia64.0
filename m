From: Christoph Hellwig <hch@infradead.org>
Date: Sat, 07 Aug 2004 10:58:54 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <20040807115854.A17606@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <200408060919.20993.jbarnes@engr.sgi.com>
In-Reply-To: <200408060919.20993.jbarnes@engr.sgi.com>; from jbarnes@engr.sgi.com on Fri, Aug 06, 2004 at 09:19:20AM -0700
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 06, 2004 at 09:19:20AM -0700, Jesse Barnes wrote:
> On Friday, August 6, 2004 6:18 am, Christoph Hellwig wrote:
> > Yikes, this is truely horrible.  First your patch ordering doesn't make
> > any sense, with just the first patch applied the system won't work at all.
> > Please submit a series of _small_ patches going from A to B keeping the
> > code working everywhere inbetween.
> 
> Much of this stuff is clearly interdependent (and dependent on PROM changes), 
> so I don't think that would make sense.

It's not.  E.g. hwgraph removal and dma code rework aren't related to hiding
of lots of interfaces in the firmware at all.

