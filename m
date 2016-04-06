From: Jonas Rabenstein <ve92mose@stud.informatik.uni-erlangen.de>
Date: Wed, 06 Apr 2016 23:12:59 +0000
Subject: [PATCH 1/3] ia64: remove unused asm/segment.h
Message-Id: <ec4e08f4908a9c7a89c2748cdd81e694434800f8.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
In-Reply-To: <cover.1459983613.git.jonas.rabenstein@studium.uni-erlangen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

From: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>

The file arch/ia64/include/asm/segment.h contains only a comment that it
is still in the source tree as it may be referenced from some files.
Actually only 2 files that are not in an arch/* directory include
<asm/segment.h>.
The first is drivers/lguest/x86/switcher_32.S and obviously is not used
by ia64.
The second is include/asm-generic/uacess.h and also not used by ia64.

Signed-off-by: Jonas Rabenstein <jonas.rabenstein@studium.uni-erlangen.de>
---
 arch/ia64/include/asm/segment.h | 6 ------
 1 file changed, 6 deletions(-)
 delete mode 100644 arch/ia64/include/asm/segment.h

diff --git a/arch/ia64/include/asm/segment.h b/arch/ia64/include/asm/segment.h
deleted file mode 100644
index b89e2b3..0000000
--- a/arch/ia64/include/asm/segment.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef _ASM_IA64_SEGMENT_H
-#define _ASM_IA64_SEGMENT_H
-
-/* Only here because we have some old header files that expect it.. */
-
-#endif /* _ASM_IA64_SEGMENT_H */
-- 
1.9.1

