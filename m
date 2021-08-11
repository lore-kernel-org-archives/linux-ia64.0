From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 11 Aug 2021 16:43:12 +0000
Subject: [PATCH] ia64: move core-y in arch/ia64/Makefile to arch/ia64/Kbuild
Message-Id: <20210811164312.187226-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: Masahiro Yamada <masahiroy@kernel.org>, linux-kernel@vger.kernel.org

Use obj-y to clean up Makefile.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/Kbuild   | 2 ++
 arch/ia64/Makefile | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/Kbuild b/arch/ia64/Kbuild
index a4e40e534e6a..e77cc76d228c 100644
--- a/arch/ia64/Kbuild
+++ b/arch/ia64/Kbuild
@@ -1 +1,3 @@
 # SPDX-License-Identifier: GPL-2.0-only
+obj-y				+= kernel/ mm/
+obj-$(CONFIG_IA64_SGI_UV)	+= uv/
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 467b7e7f967c..7e548c654a29 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -47,8 +47,6 @@ KBUILD_CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o
 
 libs-y				+= arch/ia64/lib/
-core-y				+= arch/ia64/kernel/ arch/ia64/mm/
-core-$(CONFIG_IA64_SGI_UV)	+= arch/ia64/uv/
 
 drivers-y			+= arch/ia64/pci/ arch/ia64/hp/common/
 
-- 
2.30.2
