From: Li Zefan <lizf@cn.fujitsu.com>
Date: Mon, 05 Nov 2007 02:17:24 +0000
Subject: [PATCH 2/6] IA64: fix memset size error
Message-Id: <472E7D34.1040509@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

The size arguments passing to memset is wrong.

Signed-off-by Li Zefan <lizf@cn.fujitsu.com>

---
 drivers/video/ps3fb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/video/ps3fb.c b/drivers/video/ps3fb.c
index b3463dd..75836aa 100644
--- a/drivers/video/ps3fb.c
+++ b/drivers/video/ps3fb.c
@@ -727,7 +727,7 @@ static int ps3fb_blank(int blank, struct fb_info *info)
 
 static int ps3fb_get_vblank(struct fb_vblank *vblank)
 {
-	memset(vblank, 0, sizeof(&vblank));
+	memset(vblank, 0, sizeof(*vblank));
 	vblank->flags = FB_VBLANK_HAVE_VSYNC;
 	return 0;
 }
-- 
1.5.3.rc7

