From: Robin Holt <holt@sgi.com>
Date: Wed, 28 Apr 2004 01:43:53 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <20040428014353.GA28216@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Apr 27, 2004 at 03:45:48PM -0700, David Mosberger wrote:
> 
> Yes, but that's the _easy_ part, so to speak.
> 
> To be honest, I would appreciate if you could outline your strategy to
> avoid memory-attribute aliasing.  If only because it would give me a
> warm-and-fuzzy feeling... ;-)
> 
> If this isn't something you're comfortable discussing on a public
> list, a private mail would still be appreciated.

I think this is important enough to SGI that we would like to be
included in this discussion.  One of our employees started working
on adapting what is currently the needing to be renamed fetchop
driver to take a whole granule when there are no remaining pages
in the uncached drivers space, doing the flushes, sync.i, srlz.i
sequences to ensure all cache lines are flushed and then shoot down
the existing TLB entries before adding the pages of the granule to
the uncached drivers space.  This sounds similar to what is being
proposed here, I believe.

Thanks,
Robin
