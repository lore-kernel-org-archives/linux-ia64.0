From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 20:19:34 +0000
Subject: [RFC][PATCH 01/10] put alignment macros in align.h
Message-Id: <20060829201934.A5363374@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201934.47E63D1F@localhost.localdomain>
In-Reply-To: <20060829201934.47E63D1F@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>


There are several definitions of alignment macros.  We'll take this
one out of kernel.h and put it in align.h for now.  We can't just
include kernel.h because it has many other definitions, and we'll
get circular dependencies.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/linux/kernel.h |    2 +-
 threadalloc-dave/include/linux/align.h  |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff -puN include/linux/kernel.h~align-h include/linux/kernel.h
--- threadalloc/include/linux/kernel.h~align-h	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/include/linux/kernel.h	2006-08-29 13:14:50.000000000 -0700
@@ -13,6 +13,7 @@
 #include <linux/types.h>
 #include <linux/compiler.h>
 #include <linux/bitops.h>
+#include <linux/align.h>
 #include <asm/byteorder.h>
 #include <asm/bug.h>
 
@@ -31,7 +32,6 @@ extern const char linux_banner[];
 #define STACK_MAGIC	0xdeadbeef
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
-#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
 #define FIELD_SIZEOF(t, f) (sizeof(((t*)0)->f))
 #define roundup(x, y) ((((x) + ((y) - 1)) / (y)) * (y))
 
diff -puN /dev/null include/linux/align.h
--- /dev/null	2005-03-30 22:36:15.000000000 -0800
+++ threadalloc-dave/include/linux/align.h	2006-08-29 13:14:50.000000000 -0700
@@ -0,0 +1,17 @@
+#ifndef _LINUX_ALIGN_H
+#define _LINUX_ALIGN_H
+
+/*
+ * This file should only contain macros which have no outside
+ * dependencies, and can be used safely from any other header.
+ */
+
+/*
+ * ALIGN is special.  There's a linkage.h as well that
+ * has a quite different meaning.
+ */
+#ifndef __ASSEMBLY__
+#define ALIGN(x,a) (((x)+(a)-1)&~((a)-1))
+#endif
+
+#endif /* _LINUX_ALIGN_H */
_
