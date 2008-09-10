From: Julia Lawall <julia@diku.dk>
Date: Wed, 10 Sep 2008 11:57:19 +0000
Subject: [PATCH 1/4] arch/ia64/sn/pci/tioca_provider.c: introduce missing
Message-Id: <Pine.LNX.4.64.0809101356590.15308@pc-004.diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Error handling code following a kmalloc should free the allocated data.

The semantic match that finds the problem is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@r exists@
local idexpression x;
statement S;
expression E;
identifier f,l;
position p1,p2;
expression *ptr != NULL;
@@

(
if ((x@p1 = \(kmalloc\|kzalloc\|kcalloc\)(...)) = NULL) S
|
x@p1 = \(kmalloc\|kzalloc\|kcalloc\)(...);
...
if (x = NULL) S
)
<... when != x
     when != if (...) { <+...x...+> }
x->f = E
...>
(
 return \(0\|<+...x...+>\|ptr\);
|
 return@p2 ...;
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

print "* file: %s kmalloc %s return %s" % (p1[0].file,p1[0].line,p2[0].line)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
---
 arch/ia64/sn/pci/tioca_provider.c   |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
index 529462c..7916512 100644
--- a/arch/ia64/sn/pci/tioca_provider.c
+++ b/arch/ia64/sn/pci/tioca_provider.c
@@ -420,8 +420,10 @@ tioca_dma_mapped(struct pci_dev *pdev, u64 paddr, size_t req_size)
 		entry = find_next_zero_bit(map, mapsize, last_entry);
 	}
 
-	if (entry > mapsize)
+	if (entry > mapsize) {
+		kfree(ca_dmamap);
 		goto map_return;
+	}
 
 	for (i = 0; i < entries; i++)
 		set_bit(entry + i, map);
