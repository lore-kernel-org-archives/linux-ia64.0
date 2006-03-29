From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 29 Mar 2006 20:13:30 +0000
Subject: RE: [Fedora-ia64-list] kernel 2.6.16-1.2097_FC6 unbootable on Itanium
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F061764B7@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB6DD.4020800@sgi.com>
In-Reply-To: <442AB6DD.4020800@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I also tried yesterday's snapshot 2.6.16-git17 on my tiger4, it doesn't
> boot :-(
>
> So far we have reports on:
>
> (1) 2.6.16.1 doesn't boot on altix
> (2) 2.6.16-git17 doesn't boot on tiger4
> (3) Jes's strange .section causing some hangs.

Tiger still boots with my release tree (just has seven patches that
haven't been sent to Linus yet, including Russ' fix for my merge
goof that created item "3" above).  I haven't pulled in from Linus
in about three days, so I'm about 458 commits behind the bleeding
edge.  So a "git bisect" between Linus head and the point where I last
merged (commit 64bc0430) might yield the problem (for Ken's tiger
boot issue).

-Tony

Here's what's in release/test that hasn't gone to Linus yet:

 arch/ia64/kernel/iosapic.c          |  279 +++++++++++++++++++++---------------
 arch/ia64/kernel/vmlinux.lds.S      |   18 +-
 arch/ia64/mm/init.c                 |    8 -
 arch/ia64/mm/tlb.c                  |   12 -
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    8 -
 5 files changed, 198 insertions(+), 127 deletions(-)

Chen, Kenneth W:
      [IA64] optimize flush_tlb_range on large numa box

Dean Roe:
      [IA64-SGI] fix for-loop in sn_hwperf_geoid_to_cnode()

hawkes@sgi.com:
      [IA64-SGI] sn_hwperf use of num_online_cpus()

Russ Anderson:
      [IA64] Move __mca_table out of the __init section

Satoru Takeuchi:
      [IA64] correct some messages and fixes some minor things
      [IA64] simplify some condition checks in iosapic_check_gsi_range

Zhang, Yanmin:
      [IA64] lazy_mmu_prot_update needs to be aware of huge pages
