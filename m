From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Mar 2005 18:43:41 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <16934.2397.389078.960525@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 2 Mar 2005 12:33:25 -0600, Robin Holt <holt@sgi.com> said:

  >> I wasn't suggesting to support multiple sizes, just to add a
  >> BUG_ON(size != PAGE_SIZE) or something like that.

  Robin> What is the motivation for this?

To make the kernel more resilient against inconsistencies.  Sure, it
won't be perfect, but while mucking with it anyway, why not improve
it?  Me thinks you'd want something along the lines of:

pgd_alloc:

	...
	pgd = alloc_one_fast(mm, PTRS_PER_PGD * sizeof(pgd_t));
	...

Isn't this clearer?

	--david
