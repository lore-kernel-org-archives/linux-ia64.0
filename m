From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 Sep 2004 14:24:47 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <16730.50607.403195.372875@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 17 Sep 2004 09:34:58 -0500, Robin Holt <holt@sgi.com> said:

  Robin> I have done a little testing on the uncached.  I think the
  Robin> problem may be bigger than I originally expected.

  Robin> I made a simple driver.  On load, it allocated an entire
  Robin> granule and, I think, correctly did all the flushes called
  Robin> for in the processor manual including the PAL call.  A user
  Robin> could then mmap the entire chunk as uncached and work with
  Robin> it.  I did not get any sort of MCAs from this run.

OK.

  Robin> I then started the same app which referenced the first word
  Robin> of each page uncached.  I added a timer interrupt which
  Robin> scanned all the page structs on the node from which the
  Robin> granule was allocated and had a reference to the page inside
  Robin> of an impossible if statement (next to impossible as the
  Robin> machine would have to be up for a large number of years).
  Robin> This, I believe, resulted in the speculation of the cache
  Robin> line dirty.

So you had something along the lines of:

 if (never_really_true)
   *(char *) page_address(pg) = 42;

and you got an MCA when "pg" was something pointing to the uncached
memory area?  I don't see how that would be possible unless there
already were a WB TLB entry for the granule that contains
page_address(pg).

Can you make the test-program available?  I'd be interested in trying
it out on a local machine.

	--david
