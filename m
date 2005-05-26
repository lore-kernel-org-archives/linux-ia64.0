From: Bob Picco <bob.picco@hp.com>
Date: Thu, 26 May 2005 22:04:54 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <20050526220454.GL23448@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:	[Thu May 26 2005, 04:09:06PM EDT]
> >>>>> On Tue, 24 May 2005 12:27:39 -0400, Bob Picco <bob.picco@hp.com> said:
> 
>   >> + * SECTION_SIZE_BITS            2^N: how big each section will be
> 
>   Bob> I don't perceive VIRTUAL_MEM_MAP as a nicer solution.  Actually
>   Bob> SPARSEMEM is a very elegant solution for memory holes and
>   Bob> hotplug memory.
> 
> Except that it requires configuration?  What happens if
> SECTION_SIZE_BITS is chosen wrong or poorly for a given (perhaps new)
> platform?
> 
> 	--david
> -
Yes I suppose this is a valid point.  Choosing a bad value for a very
sparse address address space or machine with small quantity of memory could 
consume lots of useless memory for section_map and/or reserved page
structures.

I'd prefer not to have a platform specific solution.  This needs to be given
some more thought.

bob
