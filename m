From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 22 Oct 2004 15:39:29 +0000
Subject: FW: Hugepages demand paging V1 [0/4]: Discussion and overview
Message-Id: <200410221537.i9MFbJq30136@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just in case someone on ia64 mailing list is interested in this subject
discussed on LKML.  Original posting:

http://marc.theaimsgroup.com/?l=linux-kernel&m9842212329631&w=2
http://marc.theaimsgroup.com/?l=linux-kernel&m9842289920357&w=2
http://marc.theaimsgroup.com/?l=linux-kernel&m9842190400028&w=2
http://marc.theaimsgroup.com/?l=linux-kernel&m9845820830658&w=2
http://marc.theaimsgroup.com/?l=linux-kernel&m9842250726548&w=2



-----Original Message-----
From: Christoph Lameter [mailto:clameter@sgi.com]
Sent: Thursday, October 21, 2004 9:55 PM
To: Chen, Kenneth W
Cc: William Lee Irwin III; raybry@sgi.com; linux-kernel@vger.kernel.org
Subject: Hugepages demand paging V1 [0/4]: Discussion and overview

This is a revised edition of the hugetlb demand page patches by
Kenneth Chen which were discussed in the following thread in August 2004

http://marc.theaimsgroup.com/?t9171285000004&r=1&w=2

The initial post by Ken was in April in

http://marc.theaimsgroup.com/?l=linux-ia64&m8189860401704&w=2

Hugetlb demand paging has been part of the production release of SuSE SLES
9 for awhile now (used by such products as Oracle) and this patchset is
intended to help hugetlb demand paging also get into the official Linux kernel.

This first version of the patchset is a collection of the patches from the
above mentioned thread in August. The key unresolved issue in that thread was
the necessity of using update_cache_mmu after setting up a huge pte.

update_cache_mmu is intended to update the mmu cache for a PAGESIZE page and
not for a huge page. The solution adopted here (as already suggested as
a possible solution in that thread) is to require an extension of
the semantics of set_huge_pte: set_huge_pte() must also do for huge pages
what update_cache_mmu does for PAGESIZE pages. For that purpose an additional
address parameter was added to set_huge_pte() which will conviently break
any old code. The patch included hopefully already fixes all occurrences
of set_huge_pte.

A linux-2.6.9-bk5 kernel with this patchset was build on IA64 and successfully
tested using a performance test program for hugetlb pages.

Note that this is the first patchset and is to be seen as discussion basis.
not as a final patchset. Please review these patches.

The patchset consists of 4 patches.

1/4 Demand Paging patch. This is the base and is mostly Ken's original work
	plus a fix that was posted later.

2/4 set_huge_pte update. This updates the set_huge_pte function for all
	architectures and insures that the arch specific action for
	update_mmu_cache is taken (which may be do nothing for some arches).
	Please verify that this really addresses the issues for each arch
	and that it is complete.

3/4 Overcommit patch: Mostly the original work by Ken plus a fix that he
	posted later.

4/4 Numa patch: Work by Raymund Bryant and myself at SGI to make
	the huge page allocator try to allocate local memory instead always
	starting at node zero. This definitely needs to be more sophisticated.

Patches 1 to 3 must be applied together. The Numa patch is optional.


