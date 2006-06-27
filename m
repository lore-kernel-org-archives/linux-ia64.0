From: Andrew Morton <akpm@osdl.org>
Date: Tue, 27 Jun 2006 08:06:46 +0000
Subject: ia64 breakage in current -git
Message-Id: <20060627010646.21ff5687.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



fyi, Linus's current tree is bust on ia64 - you get a lot of link-time
warnings about missing __udivdi3 and things.

The below will get things going again.

diff -puN Makefile~revert-ignore-makes-built-in-rules-variables Makefile
--- a/Makefile~revert-ignore-makes-built-in-rules-variables
+++ a/Makefile
@@ -276,9 +276,9 @@ MAKEFLAGS += --include-dir=$(srctree)
 # We need some generic definitions
 include  $(srctree)/scripts/Kbuild.include
 
-# Do not use make's built-in rules and variables
-# This increases performance and avoid hard-to-debug behavour
-MAKEFLAGS += -rR
+# For maximum performance (+ possibly random breakage, uncomment
+# the following)
+#MAKEFLAGS += -rR
 
 # Make variables (CC, etc...)
 
_

