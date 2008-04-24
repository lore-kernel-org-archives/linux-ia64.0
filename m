From: Alex Chiang <achiang@hp.com>
Date: Thu, 24 Apr 2008 18:57:08 +0000
Subject: Re: [PATCH 1/2] ia64: Remove printk noise on unimplemented
Message-Id: <20080424185708.GD32553@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECCBFA9D@orsmsx424.amr.corp.intel.com> <20080319233140.GD16237@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECE13C6E@orsmsx424.amr.corp.intel.com> <20080326185912.GA30749@ldl.fc.hp.com> <20080421052450.GA24055@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843EC012664E0@orsmsx424.amr.corp.intel.com> <20080424184417.GA32553@ldl.fc.hp.com> <20080424185140.GB32553@ldl.fc.hp.com>
In-Reply-To: <20080424185140.GB32553@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, lenb@kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

Ugh, next time, run checkpatch *before* sending out the patches.
Sorry for the noise.

/ac

From: Alex Chiang <achiang@hp.com>
Subject: [PATCH 1/2] ia64: Remove printk noise on unimplemented SAL_PHYSICAL_ID_INFO

Commit 113134fcbca83619be4c68d0ca66db6093777b5d changed the flow of
control when calling PAL_LOGICAL_TO_PHYSICAL and SAL_PHYSICAL_ID_INFO.
With the change, if a platform did not implement the latter, a useless
printk would appear in the boot log:

	ia64_sal_pltid failed with -1

So let's check the return code and only printk on a true error, and do
not print anything in the unimplemented case. While we're in there,
clean up some stylistic issues too.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 arch/ia64/kernel/smpboot.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 16483be..8d86e1f 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -873,7 +873,8 @@ identify_siblings(struct cpuinfo_ia64 *c)
 	u16 pltid;
 	pal_logical_to_physical_t info;
 
-	if ((status = ia64_pal_logical_to_phys(-1, &info)) != PAL_STATUS_SUCCESS) {
+	status = ia64_pal_logical_to_phys(-1, &info);
+	if (status != PAL_STATUS_SUCCESS) {
 		if (status != PAL_STATUS_UNIMPLEMENTED) {
 			printk(KERN_ERR
 				"ia64_pal_logical_to_phys failed with %ld\n",
@@ -885,8 +886,13 @@ identify_siblings(struct cpuinfo_ia64 *c)
 		info.overview_cpp  = 1;
 		info.overview_tpc  = 1;
 	}
-	if ((status = ia64_sal_physical_id_info(&pltid)) != PAL_STATUS_SUCCESS) {
-		printk(KERN_ERR "ia64_sal_pltid failed with %ld\n", status);
+
+	status = ia64_sal_physical_id_info(&pltid);
+	if (status != PAL_STATUS_SUCCESS) {
+		if (status != PAL_STATUS_UNIMPLEMENTED)
+			printk(KERN_ERR
+				"ia64_sal_pltid failed with %ld\n",
+				status);
 		return;
 	}
 
-- 
1.5.3.1.g1e61

