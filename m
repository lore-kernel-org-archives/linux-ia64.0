From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 08 Jul 2004 21:34:09 +0000
Subject: Re: Why was the PTE quicklist removed?
Message-Id: <16621.48593.536646.146461@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040707193025.GA12577@lnx-holt.americas.sgi.com>
In-Reply-To: <20040707193025.GA12577@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 7 Jul 2004 14:30:26 -0500, Robin Holt <holt@sgi.com> said:

  Robin> I looked at include/asm-ia64/pgalloc.h and noticed that someone removed
  Robin> the use of the pte_quicklist in pte_free.  When I look at the bitkeeper
  Robin> change log for this, it appears to have been removed by ChangeSet
  Robin> 1.369.41.1.

  Robin> How can I find the original author of this change?  I don't see any
  Robin> reasons given on the ia64 list for removing the quicklist code.
  Robin> Should I be looking somewhere else?

It's been over 2 years since that change, so my recollection is a bit
fuzzy, but the pte_quicklist was dropped as part of the sync-up with
the 2.5.5 kernel.  That patch introduced the hooks needed to support
PTEs that live in high memory (see
http://www.lia64.org/book/changelog.php3) and as a result, there were
a bunch of changes on how PTE directories are handled.

After that change, pte_alloc_one() used alloc_pages() instead of
__get_free_pages() to allocate the directory so on a highmem machine,
it would not necessarily be possible to maintain that page in the
quicklist anymore.  I vaguely remember there may have been another
reason to remove it, but I can't remember what it was.

	--david
