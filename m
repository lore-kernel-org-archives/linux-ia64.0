From: Robin Holt <holt@sgi.com>
Date: Wed, 29 Sep 2004 15:43:23 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <20040929154322.GA18538@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 29, 2004 at 07:24:47AM -0700, David Mosberger wrote:
> >>>>> On Fri, 17 Sep 2004 09:34:58 -0500, Robin Holt <holt@sgi.com> said:
> 
>   Robin> I have done a little testing on the uncached.  I think the
>   Robin> problem may be bigger than I originally expected.
> 
>   Robin> I made a simple driver.  On load, it allocated an entire
>   Robin> granule and, I think, correctly did all the flushes called
>   Robin> for in the processor manual including the PAL call.  A user
>   Robin> could then mmap the entire chunk as uncached and work with
>   Robin> it.  I did not get any sort of MCAs from this run.
> 
> OK.
> 
>   Robin> I then started the same app which referenced the first word
>   Robin> of each page uncached.  I added a timer interrupt which
>   Robin> scanned all the page structs on the node from which the
>   Robin> granule was allocated and had a reference to the page inside
>   Robin> of an impossible if statement (next to impossible as the
>   Robin> machine would have to be up for a large number of years).
>   Robin> This, I believe, resulted in the speculation of the cache
>   Robin> line dirty.
> 
> So you had something along the lines of:
> 
>  if (never_really_true)
>    *(char *) page_address(pg) = 42;
> 
> and you got an MCA when "pg" was something pointing to the uncached
> memory area?  I don't see how that would be possible unless there
> already were a WB TLB entry for the granule that contains
> page_address(pg).
> 
> Can you make the test-program available?  I'd be interested in trying
> it out on a local machine.

That was exactly what I did.  Unfortunately, I blew that away over a
week ago.  Sorry.  I guess I could try to recreate it.

One other thing that was going on was page zereoing of the last page
in the previous granule.  It was always an MCA on the first page of the
uncached region.  I had forgotten about that little tidbit before.  Sorry.
The more I think about it, the zereoing of the previous page may have
been the key to this failing.  Inside the timer, it would run through
all the pages exactly as you indicated.  I would then call memset with
the previous page.

For my never_really_true, I would use the upper bit of the SN2 Real-time
clock.  It remained zero throughout the tests.

Do you want me to attempt to recreate this test for you?

Thanks,
Robin
