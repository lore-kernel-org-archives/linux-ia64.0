From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 02 Mar 2005 18:53:54 +0000
Subject: Re: [Patch 1/3] Reclaim pmd and pte tables to quicklists.
Message-Id: <16934.3010.785295.246886@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050302183918.GB16517@lnx-holt.americas.sgi.com>
In-Reply-To: <20050302183918.GB16517@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 2 Mar 2005 12:39:18 -0600, Robin Holt <holt@sgi.com> said:

  Robin> This patch introduces using the quicklists for pgd, pmd, and
  Robin> pte levels by combining the alloc and free functions into a
  Robin> common set of routines.  This greatly simplifies the reading
  Robin> of this header file.

I think the patch would be more readable and would more easily fit in
80 cols if you did:

DEFINE_PER_CPU(long, __pgtable_quicklist_size);
#define pgtable_quicklist_size __ia64_per_cpu_var(__pgtable_quicklist_size)

	--david
