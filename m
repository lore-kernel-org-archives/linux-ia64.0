From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 27 Aug 2004 15:44:09 +0000
Subject: Re: Latest Altix I/O code reorganization code
Message-Id: <20040827164409.A32340@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408042014.i74KE8fD141211@fsgi900.americas.sgi.com> <20040806141836.A9854@infradead.org> <411AAABB.8070707@sgi.com> <412F4EC9.7050003@sgi.com> <412F4FCF.6010507@sgi.com> <20040827162127.A32090@infradead.org> <412F54D4.2020905@sgi.com>
In-Reply-To: <412F54D4.2020905@sgi.com>; from pfg@sgi.com on Fri, Aug 27, 2004 at 10:35:48AM -0500
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Patrick Gefre <pfg@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Aug 27, 2004 at 10:35:48AM -0500, Patrick Gefre wrote:
> The code was completely redone. It was not done in sections. Breaking them into
> pieces is nothing more than an academic exercise. It is not useable until all
> the code changes have been made because it would require a prom that followed these
> changes.  The point of a review was to get comments on the CONTENT of the code not
> the format of the patches.

This might be true for some parts, for others it certainy isn't.  E.g.
pci dma code still loooks remarkably similar to the old one, the klconfig
code is only stripped down a little, there's quite a few changes in the
headers that don't make much sense.

