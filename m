From: Jesper Juhl <jesper.juhl@gmail.com>
Date: Thu, 23 Aug 2007 23:40:26 +0000
Subject: [PATCH 01/30] ia64: Remove unnecessary cast of allocation return value in sn_hwperf_enum_objects()
Message-Id: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Message-Id: <200708240135.56833.jesper.juhl@gmail.com>>
In-Reply-To: <Message-Id: <200708240135.56833.jesper.juhl@gmail.com>>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Mark Goodwin <markgw@sgi.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Jes Sorensen <jes@sgi.com>, linux-altix@sgi.com, Jesper Juhl <jesper.juhl@gmail.com>

vmalloc() returns a void pointer - no need to cast it.

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index df8d5be..1a8e496 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -66,7 +66,8 @@ static int sn_hwperf_enum_objects(int *nobj, struct sn_hwperf_object_info **ret)
 	}
 
 	sz = sn_hwperf_obj_cnt * sizeof(struct sn_hwperf_object_info);
-	if ((objbuf = (struct sn_hwperf_object_info *) vmalloc(sz)) = NULL) {
+	objbuf = vmalloc(sz);
+	if (objbuf = NULL) {
 		printk("sn_hwperf_enum_objects: vmalloc(%d) failed\n", (int)sz);
 		e = -ENOMEM;
 		goto out;
-- 
1.5.2.2

