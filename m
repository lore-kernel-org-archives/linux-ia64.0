From: Horms <horms@verge.net.au>
Date: Mon, 02 Oct 2006 04:11:52 +0000
Subject: [patch 2/3] [IA64] kexec/kdump: Make sure vec is initialised in kexec_disable_iosapic()
Message-Id: <20061002041150.GC3034@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Date: Fri, 29 Sep 2006 14:46:23 -0700
> From: Tony Luck <tony.luck@intel.com>
> Message-Id: <200609292146.k8TLkNex005603@agluck-lia64.sc.intel.com>
> To: linux-ia64@vger.kernel.org
> Subject: kexec/kdump and the ia64 test tree
> Cc: akpm@osdl.org, horms@verge.net.au
>
> The kexec/kdump patch in my test tree is very stale, plus it is time
> for some git maintenance on the test tree (to clean away all the
> "Auto-update from upstream" commits that my workflow generates). So
> I'm planning on resetting my "test" branch to Linus-latest + kdump/kexec
> (so git pull/fetch will barf on my test tree, you'll need to re-clone).
>
> Below I've include what I believe to be the latest version of the
> patch produced by:
>
> 1) Take 2.6.18
> 2) Apply Nan Hai patch for 2.6.18 (posted Sept 20th)
> 3) Pull in Linus-latest (c972398b ...) and resolve conflicts in smp.h, sysctl.h
> 4) Apply Nan hai's "Fix OS_INIT" patch that fixed Indou-san's deadlock issue
> +(Sept 28th)
> 5) Fix a few warnings:
>         arch/ia64/kernel/iosapic.c:
>                 `vec' may be used before set in kexec_disable_iosapic() ... I'm
>                 not totally confident that I fixed this right. Please look
> +closely
>                 at what I did.
>         arch/ia64/kernel/smp.c:
>                 Trivial fixes to stop compiler complaining that
> +kdump_smp_send_stop()
>                 and kdump_smp_send_init() definitions were not prototypes.
> 6) Lots of white-space cleanup (mostly multiple spaces that should be tabs, but
> +I
>    also threw the whole kdump_find_rsvd_region() in arch/ia64/kernel/efi.c
> +through
>    scripts/Lindent as it was only using two-spaces for indentation.)
>
> Let me know if I've goofed up the patch during this process.
>
> I'm planning to reset my test tree on Monday (Oct 2nd).
>
> -Tony

This is the portion of the above patch that ensures that vec is
initialised in kexec_disable_iosapic(). But is this fix correct?

Cc: Tony Luck <tony.luck@intel.com>
Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-Off-By: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/iosapic.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

721cb78a82e98f515e932c299aa444c6d37a687f
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index c7a465d..00cf506 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -295,9 +295,10 @@ kexec_disable_iosapic(void)
 {
 	struct iosapic_intr_info *info;
 	struct iosapic_rte_info *rte;
-	u8 vec;
+	ia64_vector vec = 0;
+
 	for (info = iosapic_intr_info; info <
-			iosapic_intr_info + IA64_NUM_VECTORS; ++info) {
+			iosapic_intr_info + IA64_NUM_VECTORS; ++info, ++vec) {
 		list_for_each_entry(rte, &info->rtes,
 				rte_list) {
 			iosapic_write(rte->addr,
