From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Wed, 21 Mar 2018 19:22:18 +0000
Subject: [PATCH 02/32] docs/vm: balance: convert to ReST format
Message-Id: <1521660168-14372-3-git-send-email-rppt@linux.vnet.ibm.com>
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
 Documentation/vm/balance | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/balance b/Documentation/vm/balance
index 9645954..6a1fadf 100644
--- a/Documentation/vm/balance
+++ b/Documentation/vm/balance
@@ -1,3 +1,9 @@
+.. _balance:
+
+========
+Memory Balancing
+========
+
 Started Jan 2000 by Kanoj Sarcar <kanoj@sgi.com>
 
 Memory balancing is needed for !__GFP_ATOMIC and !__GFP_KSWAPD_RECLAIM as
@@ -62,11 +68,11 @@ for non-sleepable allocations. Second, the HIGHMEM zone is also balanced,
 so as to give a fighting chance for replace_with_highmem() to get a
 HIGHMEM page, as well as to ensure that HIGHMEM allocations do not
 fall back into regular zone. This also makes sure that HIGHMEM pages
-are not leaked (for example, in situations where a HIGHMEM page is in 
+are not leaked (for example, in situations where a HIGHMEM page is in
 the swapcache but is not being used by anyone)
 
 kswapd also needs to know about the zones it should balance. kswapd is
-primarily needed in a situation where balancing can not be done, 
+primarily needed in a situation where balancing can not be done,
 probably because all allocation requests are coming from intr context
 and all process contexts are sleeping. For 2.3, kswapd does not really
 need to balance the highmem zone, since intr context does not request
@@ -89,7 +95,8 @@ pages is below watermark[WMARK_LOW]; in which case zone_wake_kswapd is also set.
 
 
 (Good) Ideas that I have heard:
+
 1. Dynamic experience should influence balancing: number of failed requests
-for a zone can be tracked and fed into the balancing scheme (jalvo@mbay.net)
+   for a zone can be tracked and fed into the balancing scheme (jalvo@mbay.net)
 2. Implement a replace_with_highmem()-like replace_with_regular() to preserve
-dma pages. (lkd@tantalophile.demon.co.uk)
+   dma pages. (lkd@tantalophile.demon.co.uk)
-- 
2.7.4

