From: Jes Sorensen <jes@sgi.com>
Date: Fri, 17 Mar 2006 09:15:32 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <441A7E34.90508@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net>	 <20060316163728.06f49c00.akpm@osdl.org>	 <Pine.LNX.4.64.0603161659210.3618@g5.osdl.org> <1142571490.9022.37.camel@localhost.localdomain>
In-Reply-To: <1142571490.9022.37.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, cotte@de.ibm.com, Hugh Dickins <hugh@veritas.com>

Benjamin Herrenschmidt wrote:
>> Quite frankly, I don't think nopfn() is a good interface. It's only usable 
>> for one single thing, so trying to claim that it's a generic VM op is 
>> really not valid. If (and that's a big if) we need this interface, we 
>> should just do it inside mm/memory.c instead of playing games as if it was 
>> generic.
> 
> Or just use sparsemem and create struct pages for your hw :) we do that
> for SPUs on Cell, works like a charm.

Well then the question is, would it simplify the code using no_pfn in
this case? Hacking up fake struct page entries seems even more of a
hack to me.

Cheers,
Jes

