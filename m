From: Masahiro Yamada <masahiroy@kernel.org>
Date: Sat, 27 Feb 2021 05:34:50 +0000
Subject: [PATCH] ia64: remove redundant READELF from arch/ia64/Makefile
Message-Id: <20210227053450.4073222-1-masahiroy@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Masahiro Yamada <masahiroy@kernel.org>, linux-ia64@vger.kernel.org

READELF is defined by the top Makefile.

Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
---

 arch/ia64/Makefile | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 3e9da5e6c3bd..467b7e7f967c 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -14,7 +14,6 @@
 KBUILD_DEFCONFIG := generic_defconfig
 
 NM := $(CROSS_COMPILE)nm -B
-READELF := $(CROSS_COMPILE)readelf
 
 CHECKFLAGS	+= -D__ia64=1 -D__ia64__=1 -D_LP64 -D__LP64__
 
-- 
2.27.0
