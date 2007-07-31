From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 Jul 2007 02:40:07 +0000
Subject: [PATCH] flush icache before set_pte take6. [3/4] add montecito
Message-Id: <20070731114007.b3c62cd3.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070731113543.93ffd964.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "Zoltan.Menyhart@bull.net" <Zoltan.Menyhart@bull.net>, Christoph Lameter <clameter@sgi.com>

Add Brand name "Montecito" to cpuinfo.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/ia64/kernel/setup.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.23-rc1.test/arch/ia64/kernel/setup.c
=================================--- linux-2.6.23-rc1.test.orig/arch/ia64/kernel/setup.c
+++ linux-2.6.23-rc1.test/arch/ia64/kernel/setup.c
@@ -705,7 +705,8 @@ get_model_name(__u8 family, __u8 model)
 			case 0: memcpy(brand, "McKinley", 9); break;
 			case 1: memcpy(brand, "Madison", 8); break;
 			case 2: memcpy(brand, "Madison up to 9M cache", 23); break;
-		}
+		} else if (family = 0x20)
+			memcpy(brand, "Montecito", 10);
 	}
 	for (i = 0; i < MAX_BRANDS; i++)
 		if (strcmp(brandname[i], brand) = 0)

