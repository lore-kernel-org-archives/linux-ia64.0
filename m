From: Joe Perches <joe@perches.com>
Date: Tue, 25 Aug 2020 04:56:00 +0000
Subject: [PATCH 03/29] ia64: Avoid comma separated statements
Message-Id: <be37cf8fdcad19678cd164946252bc67713ddcdf.1598331148.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1598331148.git.joe@perches.com>
In-Reply-To: <cover.1598331148.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jiri Kosina <trivial@kernel.org>, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Use semicolons and braces.

Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/kernel/smpboot.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index c29c600d7967..3311b9d21319 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -224,8 +224,11 @@ get_delta (long *rt, long *master)
 		go[SLAVE] = 0;
 		t1 = ia64_get_itc();
 
-		if (t1 - t0 < best_t1 - best_t0)
-			best_t0 = t0, best_t1 = t1, best_tm = tm;
+		if (t1 - t0 < best_t1 - best_t0) {
+			best_t0 = t0;
+			best_t1 = t1;
+			best_tm = tm;
+		}
 	}
 
 	*rt = best_t1 - best_t0;
-- 
2.26.0
