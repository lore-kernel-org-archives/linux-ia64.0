From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 29 Sep 2004 16:02:47 +0000
Subject: Re: Uncached memory allocator for ia64.
Message-Id: <16730.56487.370233.247359@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
In-Reply-To: <20040914151629.GA21118@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 Sep 2004 10:43:23 -0500, Robin Holt <holt@sgi.com> said:

  Robin> One other thing that was going on was page zereoing of the
  Robin> last page in the previous granule.  It was always an MCA on
  Robin> the first page of the uncached region.  I had forgotten about
  Robin> that little tidbit before.  Sorry.  The more I think about
  Robin> it, the zereoing of the previous page may have been the key
  Robin> to this failing.  Inside the timer, it would run through all
  Robin> the pages exactly as you indicated.  I would then call memset
  Robin> with the previous page.

  Robin> Do you want me to attempt to recreate this test for you?

Well, I really think we need to get to the root of this.  What you did
_should_ work and if it doesn't, we need to understand why not.

The Alternate DTLB handler never installs a TLB-entry for speculative
accesses or for non-access instructions (such as lfetch), so it would
take an outright bug if memset() were to cause a WB TLB-entry to be
inserted for the uncached granule.  I don't think that's likely (if
memset() were broken in this way, we should have noticed _much_
earlier) but if memset() was indeed the culprit, we definitely would
want to know.

So yeah, if you could reproduce the test-case and see if it was the
memset(), that would be great!

	--david
