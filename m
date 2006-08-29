From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 21:33:24 +0000
Subject: Re: [RFC][PATCH 06/10] sparc64 generic PAGE_SIZE
Message-Id: <1156887204.5408.201.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060829201934.47E63D1F@localhost.localdomain>
	 <20060829201938.8E1B700A@localhost.localdomain>
In-Reply-To: <20060829201938.8E1B700A@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org

There's s small issue on sparc64.  PAGE_SHIFT is used in a header where
it was previously available, but isn't now.  We need page.h

diff -puN include/asm-sparc64/pgtable.h~sparc64-fix include/asm-sparc64/pgtable.h
--- threadalloc/include/asm-sparc64/pgtable.h~sparc64-fix       2006-08-29 14:18:27.000000000 -0700
+++ threadalloc-dave/include/asm-sparc64/pgtable.h      2006-08-29 14:18:28.000000000 -0700
@@ -13,6 +13,7 @@
  */

 #include <asm-generic/pgtable-nopud.h>
+#include <asm-generic/page.h>

 #include <linux/compiler.h>
 #include <asm/types.h>

-- Dave

