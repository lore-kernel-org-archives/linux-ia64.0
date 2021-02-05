From: Amy Parker <enbyamy@gmail.com>
Date: Fri, 05 Feb 2021 22:06:18 +0000
Subject: [PATCH] ia64: Fix style guide breakage
Message-Id: <20210205220618.611388-1-enbyamy@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: schnelle@linux.ibm.com, corbet@lwn.net, mchehab+huawei@kernel.org, tsbogend@alpha.franken.de
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Amy Parker <enbyamy@gmail.com>

Some statements do not have proper spacing between their C
keywords (commonly if and for) throughout files in the ia64 tree.
This patch corrects this to follow the kernel code style guide.

Signed-off-by: Amy Parker <enbyamy@gmail.com>
---
 arch/ia64/hp/common/sba_iommu.c  | 6 +++---
 arch/ia64/kernel/machine_kexec.c | 2 +-
 arch/ia64/kernel/palinfo.c       | 6 +++---
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 9148ddbf02e5..84a410f3e68f 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -139,7 +139,7 @@
 
 #ifdef ASSERT_PDIR_SANITY
 #define ASSERT(expr) \
-        if(!(expr)) { \
+        if (!(expr)) { \
                 printk( "\n" __FILE__ ":%d: Assertion " #expr " failed!\n",__LINE__); \
                 panic(#expr); \
         }
@@ -510,7 +510,7 @@ sba_search_bitmap(struct ioc *ioc, struct device *dev,
 
 	if (likely(bits_wanted = 1)) {
 		unsigned int bitshiftcnt;
-		for(; res_ptr < res_end ; res_ptr++) {
+		for (; res_ptr < res_end ; res_ptr++) {
 			if (likely(*res_ptr != ~0UL)) {
 				bitshiftcnt = ffz(*res_ptr);
 				*res_ptr |= (1UL << bitshiftcnt);
@@ -538,7 +538,7 @@ sba_search_bitmap(struct ioc *ioc, struct device *dev,
 		mask = base_mask << bitshiftcnt;
 
 		DBG_RES("%s() o %ld %p", __func__, o, res_ptr);
-		for(; res_ptr < res_end ; res_ptr++)
+		for (; res_ptr < res_end ; res_ptr++)
 		{ 
 			DBG_RES("    %p %lx %lx\n", res_ptr, mask, *res_ptr);
 			ASSERT(0 != mask);
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_kexec.c
index efc9b568401c..8de286450578 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -137,7 +137,7 @@ void machine_kexec(struct kimage *image)
 {
 	BUG_ON(!image);
 	unw_init_running(ia64_machine_kexec, image);
-	for(;;);
+	for (;;);
 }
 
 void arch_crash_save_vmcoreinfo(void)
diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index 78fa6579c9ea..ec2ff3e510c0 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -155,7 +155,7 @@ static void bitregister_process(struct seq_file *m, u64 *reg_info, int max)
 
 	value >>= i = begin = ffs(value) - 1;
 
-	for(; i < max; i++ ) {
+	for (; i < max; i++ ) {
 
 		if (i != 0 && (i%64) = 0) value = *++reg_info;
 
@@ -523,7 +523,7 @@ static void feature_set_info(struct seq_file *m, u64 avail, u64 status, u64 cont
 	int i;
 
 	vf = v = proc_features[set];
-	for(i=0; i < 64; i++, avail >>=1, status >>=1, control >>=1) {
+	for (i=0; i < 64; i++, avail >>=1, status >>=1, control >>=1) {
 
 		if (!(control))		/* No remaining bits set */
 			break;
@@ -613,7 +613,7 @@ static int bus_info(struct seq_file *m)
 	status  = st.pal_bus_features_val;
 	control = ct.pal_bus_features_val;
 
-	for(i=0; i < 64; i++, v++, avail >>=1, status >>=1, control >>=1) {
+	for (i=0; i < 64; i++, v++, avail >>=1, status >>=1, control >>=1) {
 		if ( ! *v )
 			continue;
 		seq_printf(m, "%-48s : %s%s %s\n", *v,
-- 
2.29.2
