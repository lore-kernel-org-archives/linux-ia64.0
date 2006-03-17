From: Linus Torvalds <torvalds@osdl.org>
Date: Fri, 17 Mar 2006 01:04:14 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <Pine.LNX.4.64.0603161659210.3618@g5.osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net> <20060316163728.06f49c00.akpm@osdl.org>
In-Reply-To: <20060316163728.06f49c00.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: Jes Sorensen <jes@sgi.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, cotte@de.ibm.com, Hugh Dickins <hugh@veritas.com>



On Thu, 16 Mar 2006, Andrew Morton wrote:
> 
> hm.  Is that a superset of ->nopage?  Should we be looking at
> migrating over to ->nopfn, retire ->nopage?
> 
> <looks at the ghastly stuff in do_no_page>
> 
> Maybe not...

Yeah, absolutely _not_.

If we wouldn't pass the "struct page" around, we wouldn't have anything to 
synchronize with, and each nopage() function would have to do rmap stuff.

That's actually how nopage() worked a long time ago (not rmap, but it was 
up the the low-level function to do all the page table logic etc). 
Switching to returning a structured return value and letting the generic 
VM code handle all the locking and the races was a _huge_ improvement.

So yes, the modern "->nopage()" interface is less flexible, but it's less 
flexible for a very good reason. 

Quite frankly, I don't think nopfn() is a good interface. It's only usable 
for one single thing, so trying to claim that it's a generic VM op is 
really not valid. If (and that's a big if) we need this interface, we 
should just do it inside mm/memory.c instead of playing games as if it was 
generic.

		Linus
