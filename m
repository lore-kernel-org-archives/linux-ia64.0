From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Mar 2005 17:36:19 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <16933.63891.697181.758181@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 1 Mar 2005 15:10:54 -0600, Robin Holt <holt@sgi.com> said:

  >>  Agreed, but now you implicitly assume that the directories at
  >> all levels are the same size.  I think it would be better to pass
  >> the desired size to the alloc routine such that you can at least
  >> fail noisily if somebody ever tried to use different-size
  >> directories.

  Robin> Can I skip this for now?  The old code assumed a page size
  Robin> allocation as does the new.  When I go to implement the
  Robin> 4-level page tables, we can come back and address this
  Robin> concern then.

I wasn't suggesting to support multiple sizes, just to add a
BUG_ON(size != PAGE_SIZE) or something like that.

  >> Since this is performance-critical, it's probably worthwhile to
  >> use __ia64_per_cpu_var() to access the quicklist.  That way, the
  >> address of pgtable_quicklist can be obtained with a single "addl"
  >> instruction.

  Robin> I made this change.  One thing I noticed is in contig.c and
  Robin> discontig.c, we print out the number of pages in the
  Robin> quicklists.  Should I be totalling that for all cpus and
  Robin> printing the summation?

I think so.

  Robin> Is there a better way than for_each_online_cpu() (or whatever
  Robin> it is called)?

Not that I know of.  It's hardly a performance-critical operation, so
I don't see any issues.

	--david
