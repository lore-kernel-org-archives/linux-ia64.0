From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Fri, 03 Jun 2016 08:50:27 +0000
Subject: [PATCH 4/8] kexec: ensure user memory sizes do not wrap
Message-Id: <E1b8koF-0004HM-5x@rmk-PC.armlinux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Ensure that user memory sizes do not wrap around when validating the
user input, which can lead to the following input validation working
incorrectly.

Acked-by: Baoquan He <bhe@redhat.com>
Reviewed-by: Pratyush Anand <panand@redhat.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 kernel/kexec_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 8d34308ea449..d719a4d0ef55 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -169,6 +169,8 @@ int sanity_check_segment_list(struct kimage *image)
 
 		mstart = image->segment[i].mem;
 		mend   = mstart + image->segment[i].memsz;
+		if (mstart > mend)
+			return result;
 		if ((mstart & ~PAGE_MASK) || (mend & ~PAGE_MASK))
 			return result;
 		if (mend >= KEXEC_DESTINATION_MEMORY_LIMIT)
-- 
2.1.0

