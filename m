From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 30 Jun 2014 17:37:34 +0000
Subject: [PATCH 1/1] ia64: use ARRAY_SIZE instead of sizeof/sizeof[0]
Message-Id: <1404149854-7382-1-git-send-email-fabf@skynet.be>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>, Jeremy Fitzhardinge <jeremy@goop.org>, Chris Wright <chrisw@sous-sol.org>, virtualization@lists.linux-foundation.org, linux-ia64@vger.kernel.org

Use macro definition

Cc: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Chris Wright <chrisw@sous-sol.org>
Cc: virtualization@lists.linux-foundation.org
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---

This is untested.

 arch/ia64/kernel/paravirt.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index 1b22f6d..17bb2d1 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -864,8 +864,7 @@ __initdata_or_module  unsigned long __init_or_module
 ia64_native_patch_bundle(void *sbundle, void *ebundle, unsigned long type)
 {
-	const unsigned long nelems = sizeof(ia64_native_patch_bundle_elems) /
-		sizeof(ia64_native_patch_bundle_elems[0]);
+	const unsigned long nelems = ARRAY_SIZE(ia64_native_patch_bundle_elems);
 
 	return __paravirt_patch_apply_bundle(sbundle, ebundle, type,
 					      ia64_native_patch_bundle_elems,
@@ -894,9 +893,8 @@ __initconst = {
 static void __init
 ia64_native_patch_branch(unsigned long tag, unsigned long type)
 {
-	const unsigned long nelem -		sizeof(ia64_native_branch_target) /
-		sizeof(ia64_native_branch_target[0]);
+	const unsigned long nelem = ARRAY_SIZE(ia64_native_branch_target);
+
 	__paravirt_patch_apply_branch(tag, type,
 				      ia64_native_branch_target, nelem);
 }
-- 
1.8.4.5

