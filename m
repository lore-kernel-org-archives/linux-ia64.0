From: Joe Perches <joe@perches.com>
Date: Tue, 14 Sep 2010 04:23:48 +0000
Subject: [PATCH next 02/16] arch/ia64: Use static const char * const where possible
Message-Id: <8724a87b1091dce2527278a430ba150f0beb245f.1284435709.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1284435709.git.joe@perches.com>
In-Reply-To: <cover.1284435709.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/palinfo.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/kernel/palinfo.c b/arch/ia64/kernel/palinfo.c
index fdf6f9d..77597e5 100644
--- a/arch/ia64/kernel/palinfo.c
+++ b/arch/ia64/kernel/palinfo.c
@@ -434,7 +434,7 @@ register_info(char *page)
 	unsigned long phys_stacked;
 	pal_hints_u_t hints;
 	unsigned long iregs, dregs;
-	char *info_type[]={
+	static const char * const info_type[] = {
 		"Implemented AR(s)",
 		"AR(s) with read side-effects",
 		"Implemented CR(s)",
-- 
1.7.3.rc1

