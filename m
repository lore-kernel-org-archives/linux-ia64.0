From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Fri, 20 Feb 2004 19:36:38 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <01EF044AAEE12F4BAAD955CB75064943F96C99@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Recently there have been couple of feature extensions requests for
hugetlb support.  Boot time option is one of them.  Run-time
modification of HUGE_PAGE_SIZE is another one.

Ken is currently in the process of providing the support for boot time
configuration for huge page size.  As long as there are only two
supported page sizes (PAGE_SIZE and HPAGE_SIZE), it is possible to
achieve the boot time configuration of HUGE_PAGE_SIZE without needing to
patch the kernel (and possibly better packing the vhpt fault handler
code).  We will ship the patch out to the list.

Thanks, rohit

_>-----Original Message-----
_>From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
_>owner@vger.kernel.org] On Behalf Of Chen, Kenneth W
_>Sent: Thursday, February 19, 2004 8:00 PM
_>To: Jack Steiner; linux-ia64@vger.kernel.org
_>Subject: RE: HUGEPAGE SIZE a boottime option
_>
_>It is not functionally complete though.  alloc_fresh_huge_page(),
_>hugetlb_free_pgtables(), and update_and_free_page has #define constant
_>that indirectly from HPAGE_SHIFT.
_>
_>You might checked already, text replication works in this case?
_>
_>I have more comments, will post later ...
_>
_>- Ken
_>
_>
_>-----Original Message-----
_>From: linux-ia64-owner@vger.kernel.org
_>[mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Jack Steiner
_>Sent: Thursday, February 19, 2004 5:08 PM
_>To: linux-ia64@vger.kernel.org
_>Subject: HUGEPAGE SIZE a boottime option
_>
_>
_>Here is a preliminary version of a patch that makes the size of
_>HUGEPAGES a boottime option. Only ia64-specific files are changed
(except
_>for the Documentation file).
_>
_>We have a number of customers using large pages. Unfortunately,
_>the "optimum" size of a large page is application & configuration
_>dependent. Rather that having each customer recompile to specify their
_>own HUGEPAGESIZE, this patch make the size a boottime option.
_>
_>
_>Does this patch look reasonable? If so, I will incorporate feedback,
_>finish testing it, update it to 2.6.3 & resubmit.
_>-
_>To unsubscribe from this list: send the line "unsubscribe linux-ia64"
in
_>the body of a message to majordomo@vger.kernel.org
_>More majordomo info at  http://vger.kernel.org/majordomo-info.html
