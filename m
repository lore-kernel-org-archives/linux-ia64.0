From: Andy Whitcroft <apw@shadowen.org>
Date: Wed, 01 Jun 2005 09:14:36 +0000
Subject: Re: [patch 0/4] ia64 SPARSEMEM
Message-Id: <429D7C7C.2090701@shadowen.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony wrote:
> Dave Hansen wrote:
> 
>>* The same implementation works everywhere, on every architecture.
> 
> Truth in advertising might require that this patch be renamed as
> "SOMEWHATSPARSE", as it breaks down for extremely sparse physical
> address space machines.  It looks like the existing SGI Altix is at
> the ragged edge of what can be practically supported.

> Overall the SPARSEMEM patch is a good clean-up to an area of code that is
> unspeakably complex (because of all the interactions between NUMA, DISCONTIG,
> and VIRT_MEM_MAP).  So I'm in full agreement that something needs to be done.
> I'm just not convinced yet that the existing form of the SPARSEMEM patch is
> the greatest thing since sliced bread.

As Dave has already indicated the key here is that this is a common
implementation.  As the code stood we had a common implementation of
'flat' memory.  We had per-architecture memory models where this was not
sufficient.  Over time a number of key architectures have met the
non-contigious problem and solved it in nearly the same manner.  What we
set out to do was to try and provide a common implementation for a more
complex discontigious memory format.

SPARSEMEM isn't trying to be the answer for every problem, more a simple
and clean implementation which would fix the majority of the current
users well.  Where that was insufficient we still have the option of an
architecture specific memory model and significant effort has been made
in the foundations already accepted to make them usable by such an
implementation.

That said, it also was expected that SPARSEMEM would form the foundation
for more complex memory models.  As you mention there are already some
big iron machines which push the simplistic mapping we currently have to
the very limit and probabally beyond.  As Dave says if this is fixed in
SPARSEMEM then we gain for any other architecture that finds itself up
against the limits.

-apw
