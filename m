From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 19:22:45 +0000
Subject: [PATCH 29/32] docs/vm: zsmalloc.txt: convert to ReST format
Message-Id: <1521660168-14372-30-git-send-email-rppt@linux.vnet.ibm.com>
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
 Documentation/vm/zsmalloc.txt | 60 ++++++++++++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 24 deletions(-)

diff --git a/Documentation/vm/zsmalloc.txt b/Documentation/vm/zsmalloc.txt
index 64ed63c..6e79893 100644
--- a/Documentation/vm/zsmalloc.txt
+++ b/Documentation/vm/zsmalloc.txt
@@ -1,5 +1,8 @@
+.. _zsmalloc:
+
+====
 zsmalloc
---------
+====
 
 This allocator is designed for use with zram. Thus, the allocator is
 supposed to work well under low memory conditions. In particular, it
@@ -31,40 +34,49 @@ be mapped using zs_map_object() to get a usable pointer and subsequently
 unmapped using zs_unmap_object().
 
 stat
-----
+==
 
 With CONFIG_ZSMALLOC_STAT, we could see zsmalloc internal information via
-/sys/kernel/debug/zsmalloc/<user name>. Here is a sample of stat output:
+``/sys/kernel/debug/zsmalloc/<user name>``. Here is a sample of stat output::
 
-# cat /sys/kernel/debug/zsmalloc/zram0/classes
+ # cat /sys/kernel/debug/zsmalloc/zram0/classes
 
  class  size almost_full almost_empty obj_allocated   obj_used pages_used pages_per_zspage
-    ..
-    ..
+    ...
+    ...
      9   176           0            1           186        129          8                4
     10   192           1            0          2880       2872        135                3
     11   208           0            1           819        795         42                2
     12   224           0            1           219        159         12                4
-    ..
-    ..
+    ...
+    ...
+
 
+class
+	index
+size
+	object size zspage stores
+almost_empty
+	the number of ZS_ALMOST_EMPTY zspages(see below)
+almost_full
+	the number of ZS_ALMOST_FULL zspages(see below)
+obj_allocated
+	the number of objects allocated
+obj_used
+	the number of objects allocated to the user
+pages_used
+	the number of pages allocated for the class
+pages_per_zspage
+	the number of 0-order pages to make a zspage
 
-class: index
-size: object size zspage stores
-almost_empty: the number of ZS_ALMOST_EMPTY zspages(see below)
-almost_full: the number of ZS_ALMOST_FULL zspages(see below)
-obj_allocated: the number of objects allocated
-obj_used: the number of objects allocated to the user
-pages_used: the number of pages allocated for the class
-pages_per_zspage: the number of 0-order pages to make a zspage
+We assign a zspage to ZS_ALMOST_EMPTY fullness group when n <= N / f, where
 
-We assign a zspage to ZS_ALMOST_EMPTY fullness group when:
-      n <= N / f, where
-n = number of allocated objects
-N = total number of objects zspage can store
-f = fullness_threshold_frac(ie, 4 at the moment)
+* n = number of allocated objects
+* N = total number of objects zspage can store
+* f = fullness_threshold_frac(ie, 4 at the moment)
 
 Similarly, we assign zspage to:
-      ZS_ALMOST_FULL  when n > N / f
-      ZS_EMPTY        when n = 0
-      ZS_FULL         when n = N
+
+* ZS_ALMOST_FULL  when n > N / f
+* ZS_EMPTY        when n = 0
+* ZS_FULL         when n = N
-- 
2.7.4

