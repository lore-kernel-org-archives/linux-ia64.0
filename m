From: Hedi Berriche <hedi@berriche.co.uk>
Date: Tue, 23 Feb 2010 01:25:11 +0000
Subject: [2.6.33-rcX][regression] commit e8c93f breaks sn2 build
Message-Id: <20100223012511.GB24871@berriche.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[[ For a yet to be determined reason I seem to be unable to post to this list using
my sgi.com address, sending this email from an alternative address, apologies if/when
the problem gets fixed we end with duplicate messages ]]

Tony,

Here's the chronologically sorted commits that led to the problem at hand:

    - commit 204fba4aa303ea4a7bb726a539bf4a5b9e3203d0
       Author: Tejun Heo <tj@kernel.org>
       Date:   Wed Jun 24 15:13:45 2009 +0900

       percpu: cleanup percpu array definitions

    broke the sn2 build.

    - commit b94b08081fcecf83fa690d6c5664f6316fe72208
        Author: Randy Dunlap <randy.dunlap@oracle.com>
        Date:   Wed Oct 14 15:10:03 2009 -0700

        [IA64] fix percpu warnings

        Fix percpu types warning in ia64/sn:

        arch/ia64/sn/kernel/setup.c:74: error: conflicting types for '__pcpu_scope___sn_cnodeid_to_nasid'
        arch/ia64/include/asm/sn/arch.h:74: error: previous declaration of '__pcpu_scope___sn_cnodeid_to_nasid' was here

   fixed the build problem but because of genksysms not being able to properly
    parse the per-cpu array declaration, we ended up with the following problem:

           WARNING: "per_cpu____sn_cnodeid_to_nasid" [drivers/misc/sgi-xp/xpc.ko] has no CRC!

    - commit e8c93fc7b7221b6ac7e7ddbd0e21e205bf9e801a
      Author: Tony Luck <tony.luck@intel.com>
      Date:   Mon Nov 2 09:23:08 2009 -0800

      Revert "[IA64] fix percpu warnings"

      This reverts commit b94b08081fcecf83fa690d6c5664f6316fe72208.

    reverted b94b08 but in doing do got us back to a broken build state.

Until genksyms is fixed/improved should we just revert the bit of commit 204fba4
that pertains to arch/ia64/sn/kernel/setup.c?

Cheers,
Hedi.

P.S. http://marc.info/?l=linux-ia64&m5555886516823&w=2 for the detailed history...

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index ece1bf9..e456f06 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -71,7 +71,7 @@ EXPORT_SYMBOL(sn_rtc_cycles_per_second);
 DEFINE_PER_CPU(struct sn_hub_info_s, __sn_hub_info);
 EXPORT_PER_CPU_SYMBOL(__sn_hub_info);
 
-DEFINE_PER_CPU(short [MAX_COMPACT_NODES], __sn_cnodeid_to_nasid);
+DEFINE_PER_CPU(short, __sn_cnodeid_to_nasid[MAX_COMPACT_NODES]);
 EXPORT_PER_CPU_SYMBOL(__sn_cnodeid_to_nasid);
 
 DEFINE_PER_CPU(struct nodepda_s *, __sn_nodepda);
