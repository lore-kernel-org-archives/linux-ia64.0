From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 06 Aug 2004 16:19:20 +0000
Subject: Re: Altix I/O code reorganization
Message-Id: <200408060919.20993.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org>
In-Reply-To: <20040806141836.A9854@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Pat Gefre <pfg@sgi.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Friday, August 6, 2004 6:18 am, Christoph Hellwig wrote:
> Yikes, this is truely horrible.  First your patch ordering doesn't make
> any sense, with just the first patch applied the system won't work at all.
> Please submit a series of _small_ patches going from A to B keeping the
> code working everywhere inbetween.

Much of this stuff is clearly interdependent (and dependent on PROM changes), 
so I don't think that would make sense.

Jesse
