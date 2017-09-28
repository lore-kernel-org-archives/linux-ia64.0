From: Bhumika Goyal <bhumirks@gmail.com>
Date: Thu, 28 Sep 2017 15:29:35 +0000
Subject: [PATCH] [IA64] sn: make sn_screen_info const, static and __initconst
Message-Id: <1506611855-20098-1-git-send-email-bhumirks@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: julia.lawall@lip6.fr, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>

Make this structure static as it is only used in the file in which it is
defined. Make it const as it is only used during a copy operation. Make
it __initconst as this usage is during the init phase.

Structure found using Coccinelle and changes done by hand.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 arch/ia64/sn/kernel/setup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 5f6b6b4..5f4b15f 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -110,7 +110,7 @@
  * code. This is just enough to make the console code think we're on a
  * VGA color display.
  */
-struct screen_info sn_screen_info = {
+static const struct screen_info sn_screen_info __initconst = {
 	.orig_x = 0,
 	.orig_y = 0,
 	.orig_video_mode = 3,
-- 
1.9.1

