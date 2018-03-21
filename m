From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 19:22:35 +0000
Subject: [PATCH 19/32] docs/vm: page_owner: convert to ReST format
Message-Id: <1521660168-14372-20-git-send-email-rppt@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/vm/page_owner.txt | 34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/Documentation/vm/page_owner.txt b/Documentation/vm/page_owner.txt
index ffff143..0ed5ab8 100644
--- a/Documentation/vm/page_owner.txt
+++ b/Documentation/vm/page_owner.txt
@@ -1,7 +1,11 @@
+.. _page_owner:
+
+=========================
 page owner: Tracking about who allocated each page
------------------------------------------------------------
+=========================
 
-* Introduction
+Introduction
+======
 
 page owner is for the tracking about who allocated each page.
 It can be used to debug memory leak or to find a memory hogger.
@@ -34,13 +38,15 @@ not affect to allocation performance, especially if the static keys jump
 label patching functionality is available. Following is the kernel's code
 size change due to this facility.
 
-- Without page owner
+- Without page owner::
+
    text    data     bss     dec     hex filename
-  40662    1493     644   42799    a72f mm/page_alloc.o
+   40662   1493     644   42799    a72f mm/page_alloc.o
+
+- With page owner::
 
-- With page owner
    text    data     bss     dec     hex filename
-  40892    1493     644   43029    a815 mm/page_alloc.o
+   40892   1493     644   43029    a815 mm/page_alloc.o
    1427      24       8    1459     5b3 mm/page_ext.o
    2722      50       0    2772     ad4 mm/page_owner.o
 
@@ -62,21 +68,23 @@ are catched and marked, although they are mostly allocated from struct
 page extension feature. Anyway, after that, no page is left in
 un-tracking state.
 
-* Usage
+Usage
+==+
+1) Build user-space helper::
 
-1) Build user-space helper
 	cd tools/vm
 	make page_owner_sort
 
-2) Enable page owner
-	Add "page_owner=on" to boot cmdline.
+2) Enable page owner: add "page_owner=on" to boot cmdline.
 
 3) Do the job what you want to debug
 
-4) Analyze information from page owner
+4) Analyze information from page owner::
+
 	cat /sys/kernel/debug/page_owner > page_owner_full.txt
 	grep -v ^PFN page_owner_full.txt > page_owner.txt
 	./page_owner_sort page_owner.txt sorted_page_owner.txt
 
-	See the result about who allocated each page
-	in the sorted_page_owner.txt.
+   See the result about who allocated each page
+   in the ``sorted_page_owner.txt``.
-- 
2.7.4

