From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 13 Apr 2004 23:17:04 +0000
Subject: hugetlb demand paging patch part [0/3]
Message-Id: <200404132317.i3DNH4F21162@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, lse-tech@lists.sourceforge.net
Cc: raybry@sgi.com, 'Andy Whitcroft' <apw@shadowen.org>, Andrew Morton <akpm@osdl.org>

In addition to the hugetlb commit handling that we've been working on
off the list, Ray Bryant of SGI and I are also working on demand paging
for hugetlb page.  Here are our final version that has been heavily
tested on ia64 and x86.  I've broken the patch into 3 pieces so it's
easier to read/review, etc.

1. hugetlb_fix_pte.patch - with demand paging, we can not unconditionally
   assume valid pmd/pte.  Fix it up in arch specific huge_pge_offset()
   and have all caller check the return value.

2. hugetlb_demand_generic.patch - this handles bulk of hugetlb demand
   paging for generic portion of the kernel.  I've put hugetlb fault
   handler in mm/hugetlbpage.c since the fault handler is *exactly* the
   same for all arch, but that requires opening up huge_pte_alloc() and
   set_huge_pte() functions in each arch.  If people object where it
   should live.  It takes me less than a minute to delete the common
   code and replicate it in each of the 5 arch that supports hugetlb.
   Just let me know if that's the case.

3. hugetlb_demand_arch.patch - this adds additional arch specific fixes
   for x84 and ia64 when generic demand paging is turned on.  Also bulk
   of the patch is to clean up with functions that no longer needed.

Some caveats:  I don't have sh and sparc64 hardware to test.  But hugetlb
code in these two arch looked like a triplet twin of x86 code.  So I'm
pretty sure it will work right out of box.  I've monkeyed around with
ppc64 code and after a while I realized it should be left for the experts.
I'm sure there are plenty ppc64 developers out there that can get it done
in no time.

Patches relative to linux-2.6.5-mm4 and on top of hugetlb overcommit
handling patch posted by Andy Whitcroft.

Andrew, would you please review and consider for -mm?  Thanks.

- Ken


