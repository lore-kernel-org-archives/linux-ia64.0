From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 19 Jun 2004 04:52:48 +0000
Subject: Re: BUG: call to free_huge_page in arch_hugeltb_fault
Message-Id: <16595.50848.432656.169136@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3AA03342E913FA4BA6D8BD0732BFC74B02409B0A@pdsmsx402.pd.intel.com>
In-Reply-To: <3AA03342E913FA4BA6D8BD0732BFC74B02409B0A@pdsmsx402.pd.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 19 Jun 2004 09:30:04 +0800, "Zhang, Yanmin" <yanmin.zhang@intel.com> said:

  Yanmin> In base kernel 2.6.7, there is bug in function
  Yanmin> arch_hugeltb_fault. The call to free_huge_page is
  Yanmin> incorrect. I change it to page_cache_release.  On i386, it
  Yanmin> also has the same problem and I fix both in the below patch.
  Yanmin> As a matter of fact, it seems all platforms which support
  Yanmin> hugetlb page have such problem.

I put the ia64-portion of the patch in my tree.

Thanks,

	--david
