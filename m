From: "Zhang, Xiantao" <xiantao.zhang@intel.com>
Date: Thu, 28 Apr 2011 00:26:48 +0000
Subject: RE: [PATCH] ia64-kvm: fix sparse warnings
Message-Id: <BC00F5384FCFC9499AF06F92E8B78A9E2062639727@shsmsx502.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4DB85B0F.2010008@suse.com>
In-Reply-To: <4DB85B0F.2010008@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Avi, 
  Can you take this patch to kvm.git ?  Thanks!
Acked-by: Xiantao Zhang <xiantao.zhang@intel.com>

-----Original Message-----
From: Jeff Mahoney [mailto:jeffm@suse.com] 
Sent: Thursday, April 28, 2011 2:06 AM
To: Zhang, Xiantao; Avi Kivity; Luck, Tony; Yu, Fenghua
Cc: linux-ia64@vger.kernel.org
Subject: [PATCH] ia64-kvm: fix sparse warnings

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
