From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Mar 2005 21:21:05 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte entries to quicklists.
Message-Id: <16934.11841.391406.192152@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142541.GE10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 2 Mar 2005 14:44:37 -0600, Robin Holt <holt@sgi.com> said:

  >> pgd_alloc:

  >> ...  pgd = alloc_one_fast(mm, PTRS_PER_PGD * sizeof(pgd_t));

  Robin> Since the size of page tables does not change on a running
  Robin> system, would you accept three BUG_ONs in mm/init.c that
  Robin> check pgd, pmd, and pte allocation sizes?  That will be
  Robin> clearer and definitely not have any chance of impacting
  Robin> runtime.

I suppose that's OK.  I still think the above interface is clearer,
but understand that the impact would be bigger on the existing patch.

	--david
