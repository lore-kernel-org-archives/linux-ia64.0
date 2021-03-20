From: Bhaskar Chowdhury <unixbhaskar@gmail.com>
Date: Sat, 20 Mar 2021 18:35:47 +0000
Subject: [PATCH] IA64: Trivial spelling fixes
Message-Id: <20210320182347.21440-1-unixbhaskar@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: unixbhaskar@gmail.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: rdunlap@infradead.org


s/seralize/serialize/ .....three different places

Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>
---
 arch/ia64/kernel/pal.S | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
index d3e22c018b68..06d01a070aae 100644
--- a/arch/ia64/kernel/pal.S
+++ b/arch/ia64/kernel/pal.S
@@ -86,7 +86,7 @@ GLOBAL_ENTRY(ia64_pal_call_static)
 	mov ar.pfs = loc1
 	mov rp = loc0
 	;;
-	srlz.d				// seralize restoration of psr.l
+	srlz.d				// serialize restoration of psr.l
 	br.ret.sptk.many b0
 END(ia64_pal_call_static)
 EXPORT_SYMBOL(ia64_pal_call_static)
@@ -194,7 +194,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_static)
 	mov rp = loc0
 	;;
 	mov ar.rsc=loc4			// restore RSE configuration
-	srlz.d				// seralize restoration of psr.l
+	srlz.d				// serialize restoration of psr.l
 	br.ret.sptk.many b0
 END(ia64_pal_call_phys_static)
 EXPORT_SYMBOL(ia64_pal_call_phys_static)
@@ -252,7 +252,7 @@ GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	mov rp = loc0
 	;;
 	mov ar.rsc=loc4			// restore RSE configuration
-	srlz.d				// seralize restoration of psr.l
+	srlz.d				// serialize restoration of psr.l
 	br.ret.sptk.many b0
 END(ia64_pal_call_phys_stacked)
 EXPORT_SYMBOL(ia64_pal_call_phys_stacked)
--
2.26.2
