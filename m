From: "David S. Miller" <davem@davemloft.net>
Date: Sat, 08 Jan 2005 21:56:36 +0000
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <20050108135636.6796419a.davem@davemloft.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
	<Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hugh Dickins <hugh@veritas.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 8 Jan 2005 21:12:10 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Christoph, a late comment: doesn't this effectively replace
> do_anonymous_page's clear_user_highpage by clear_highpage, which would
> be a bad idea (inefficient? or corrupting?) on those few architectures
> which actually do something with that user addr?

Good catch, it probably does.  We really do need to use
the page clearing routines that pass in the user virtual
address when preparing new anonymous pages or else we'll
get cache aliasing problems on sparc, sparc64, and mips
at the very least.  That is what the virtual address argument
was added for to begin with.

The other way to deal with this is to make whatever routine
the kscrubd thing invokes do all the cache flushing et al.
magic so that the above works when taking pages from the
pre-zero'd pool (only, if no pre-zero'd pages are available
we sill need to invoke clear_user_highpage() with the proper
virtual address).
