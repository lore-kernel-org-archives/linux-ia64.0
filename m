From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sat, 27 Feb 2021 05:35:12 +0000
Subject: [PATCH] ia64: add arch/ia64/Kbuild
Message-Id: <20210227053512.4073366-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, linux-ia64@vger.kernel.org

Use the standard obj-y form to specify the sub-directories under
arch/ia64/. No functional change intended.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/Kbuild   | 3 +++
 arch/ia64/Makefile | 3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)
 create mode 100644 arch/ia64/Kbuild

diff --git a/arch/ia64/Kbuild b/arch/ia64/Kbuild
new file mode 100644
index 000000000000..e77cc76d228c
--- /dev/null
+++ b/arch/ia64/Kbuild
@@ -0,0 +1,3 @@
+# SPDX-License-Identifier: GPL-2.0-only
+obj-y				+= kernel/ mm/
+obj-$(CONFIG_IA64_SGI_UV)	+= uv/
diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 467b7e7f967c..096d5500e6a4 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -47,8 +47,7 @@ KBUILD_CFLAGS += $(cflags-y)
 head-y := arch/ia64/kernel/head.o
 
 libs-y				+= arch/ia64/lib/
-core-y				+= arch/ia64/kernel/ arch/ia64/mm/
-core-$(CONFIG_IA64_SGI_UV)	+= arch/ia64/uv/
+core-y				+= arch/ia64/
 
 drivers-y			+= arch/ia64/pci/ arch/ia64/hp/common/
 
-- 
2.27.0
