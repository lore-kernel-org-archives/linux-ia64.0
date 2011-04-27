From: Jeff Mahoney <jeffm@suse.com>
Date: Wed, 27 Apr 2011 18:06:07 +0000
Subject: [PATCH] ia64-kvm: fix sparse warnings
Message-Id: <4DB85B0F.2010008@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch fixes some sparse warning about "dubious one-bit signed bitfield."

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
Originally-by: Jan Blunck <jblunck@suse.de>
Signed-off-by: Jan Blunck <jblunck@suse.de>
---
 arch/ia64/kvm/vti.h |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

--- a/arch/ia64/kvm/vti.h
+++ b/arch/ia64/kvm/vti.h
@@ -83,13 +83,13 @@
 union vac {
 	unsigned long value;
 	struct {
-		int a_int:1;
-		int a_from_int_cr:1;
-		int a_to_int_cr:1;
-		int a_from_psr:1;
-		int a_from_cpuid:1;
-		int a_cover:1;
-		int a_bsw:1;
+		unsigned int a_int:1;
+		unsigned int a_from_int_cr:1;
+		unsigned int a_to_int_cr:1;
+		unsigned int a_from_psr:1;
+		unsigned int a_from_cpuid:1;
+		unsigned int a_cover:1;
+		unsigned int a_bsw:1;
 		long reserved:57;
 	};
 };
@@ -97,12 +97,12 @@ union vac {
 union vdc {
 	unsigned long value;
 	struct {
-		int d_vmsw:1;
-		int d_extint:1;
-		int d_ibr_dbr:1;
-		int d_pmc:1;
-		int d_to_pmd:1;
-		int d_itm:1;
+		unsigned int d_vmsw:1;
+		unsigned int d_extint:1;
+		unsigned int d_ibr_dbr:1;
+		unsigned int d_pmc:1;
+		unsigned int d_to_pmd:1;
+		unsigned int d_itm:1;
 		long reserved:58;
 	};
 };
-- 
Jeff Mahoney
SUSE Labs
