From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 26 Feb 2004 05:18:57 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <16445.33217.472790.188648@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 25 Feb 2004 17:26:25 -0800, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> We believe we have resolved all the remain issues, all critical
  Ken> speed path has been taken care of, i.e., vhpt hander and
  Ken> context switch.  There should be no performance penalty with
  Ken> this dynamic hugetlb page size feature.

What about huge-page page-faults?  Before, HPAGE_SHIFT, HPAGE_SIZE,
and HPAGE_MASK all were constant, now they have to be fetched from
memory/recalculated each time.  I suppose it's rare enough that it's
not worth worrying about but did you verify that there is at least not
anything really gross going on (like someone doing a modulo operation
against HPAGE_SIZE)?

How about replacing 0x8000000000000000 with (REGION_HPAGE <<
REGION_SHIFT) or a manifest constant defined to this value (perhaps
HUGETLB_REGION_ADDR)?

Why does the region register get initialized both in mm/init.c and
hugetlb_setup_sz()?  Couldn't this be done once in hugetlb_init()?

Other than that, the patch looks good to me.

	--david

