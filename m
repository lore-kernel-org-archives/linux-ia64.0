From: Christopher Wedgwood <cw@sgi.com>
Date: Tue, 29 Jul 2003 22:07:01 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105951682217831@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jul 29, 2003 at 02:31:58PM -0700, David Mosberger wrote:
> I'm sorry, but that's _exactly_ the problem.  You are pushing an
> SN2-specific hacks into the ia64 kernel and you seem to think that's
> OK.

Right now I'm more than happy to put the current code into the driver.
Going forward though a more generic solution would be nice.

> If you want something in the normal ia64 kernel, please propose an
> API (and patch) that actually makes sense beyond SN2.

Sure thing.  I'm not bothered for 2.4.x (the driver can carry the
required allocator) but for 2.6.x hopefully we can get something
sorted.


On Tue, Jul 29, 2003 at 02:34:53PM -0700, Luck, Tony wrote:
> Initially the UC allocator should be really, really basic.  Perhaps
> just handing out pages, and without any "free" code to complicate it
> (MCA code should only need to allocate an alternate min_state area
> for each cpu to handle returning to a different context from the one
> that was running when the fault was reported).

Page granularity would be fine here.  I'm not sure anything more
complex would be required any time soon if ever.

We could like to be able to allocate from or near to a given node in
NUMA configurations.  When allocating pages for MINSTATE areas you can
then have that code try to allocate memory on the same node as the
appropriate CPU.

How about something like:

    void* ia64_alloc_uc_page(int nodeid);
    void ia64_free_us_page(void*);

as a starting point (for non-NUMA the nodeid won't be interesting of
course).

Ideally freeing memory shouldn't be that hard and for fetchop
certainly would be desirable.  We could probably get by with a naive
bitmap allocator per-node or even one of wli's alternative bootmem
allocator suggestions (massaged to suit).



  --cw
