From: Julia Lawall <julia@diku.dk>
Date: Fri, 27 Aug 2010 21:01:30 +0000
Subject: [PATCH 2/2] arch/ia64/kernel: Move up iounmap
Message-Id: <1282942890-465-2-git-send-email-julia@diku.dk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: kernel-janitors@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

By moving the iounmap up above the test, it takes place whether the test
succeeds or fails.

The sematic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
local idexpression x;
expression E,E1;
identifier l;
statement S;
@@

*x = ioremap_nocache(...);
...
if (x = NULL) S
... when != iounmap(x)
    when != if (...) { ... iounmap(x); ... }
    when != E = x
if (...) {
  ... when != iounmap(x)
      when != if (...) { ... iounmap(x); ... }
(
  return <+...x...+>;
|
* return ...;
)
}
... when != x = E1
iounmap(x);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 arch/ia64/kernel/cyclone.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
index 71e3586..d52f1f7 100644
--- a/arch/ia64/kernel/cyclone.c
+++ b/arch/ia64/kernel/cyclone.c
@@ -59,13 +59,13 @@ int __init init_cyclone_clock(void)
 		return -ENODEV;
 	}
 	base = readq(reg);
+	iounmap(reg);
 	if(!base){
 		printk(KERN_ERR "Summit chipset: Could not find valid CBAR"
 				" value.\n");
 		use_cyclone = 0;
 		return -ENODEV;
 	}
-	iounmap(reg);
 
 	/* setup PMCC */
 	offset = (base + CYCLONE_PMCC_OFFSET);

