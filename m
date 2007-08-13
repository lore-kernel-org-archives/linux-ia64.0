From: joe@perches.com
Date: Mon, 13 Aug 2007 06:29:10 +0000
Subject: [PATCH] [235/2many] MAINTAINERS - IA64 (Itanium) PLATFORM
Message-Id: <46bffa36.aUiLcDMm3snOLBwG%joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: torvalds@linux-foundation.org, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, akpm@linux-foundation.org

Add file pattern to MAINTAINER entry

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 802960b..f68199b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2237,6 +2237,8 @@ L:	linux-ia64@vger.kernel.org
 W:	http://www.ia64-linux.org/
 T:	git kernel.org:/pub/scm/linux/kernel/git/aegl/linux-2.6.git
 S:	Maintained
+F:	arch/ia64/
+F:	include/asm-ia64/*
 
 SN-IA64 (Itanium) SUB-PLATFORM
 P:	Jes Sorensen
