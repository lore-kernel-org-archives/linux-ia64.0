From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 20 Feb 2004 04:00:04 +0000
Subject: RE: HUGEPAGE SIZE a boottime option
Message-Id: <B05667366EE6204181EABE9C1B1C0EB501F2AAFE@scsmsx401.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040220010731.GA28820@sgi.com>
In-Reply-To: <20040220010731.GA28820@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It is not functionally complete though.  alloc_fresh_huge_page(), hugetlb_free_pgtables(), and update_and_free_page has #define constant that indirectly from HPAGE_SHIFT.

You might checked already, text replication works in this case?

I have more comments, will post later ...

- Ken


-----Original Message-----
From: linux-ia64-owner@vger.kernel.org
[mailto:linux-ia64-owner@vger.kernel.org]On Behalf Of Jack Steiner
Sent: Thursday, February 19, 2004 5:08 PM
To: linux-ia64@vger.kernel.org
Subject: HUGEPAGE SIZE a boottime option


Here is a preliminary version of a patch that makes the size of
HUGEPAGES a boottime option. Only ia64-specific files are changed (except
for the Documentation file).

We have a number of customers using large pages. Unfortunately, 
the "optimum" size of a large page is application & configuration
dependent. Rather that having each customer recompile to specify their
own HUGEPAGESIZE, this patch make the size a boottime option.


Does this patch look reasonable? If so, I will incorporate feedback,
finish testing it, update it to 2.6.3 & resubmit.
