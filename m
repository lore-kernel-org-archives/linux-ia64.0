From: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>
Date: Wed, 18 Feb 2004 07:43:27 +0000
Subject: [PATCH] possible memory leak fix
Message-Id: <20040218.164327.74757142.maeda@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I found a possible memory leak problem in alloc_resource().
The following patch against 2.6.3 fix the problem.

Regards,
- Naoaki Maeda

diff -Naur linux-2.6.3.org/arch/ia64/pci/pci.c linux-2.6.3/arch/ia64/pci/pci.c
--- linux-2.6.3.org/arch/ia64/pci/pci.c	2004-02-18 12:57:46.000000000 +0900
+++ linux-2.6.3/arch/ia64/pci/pci.c	2004-02-18 16:36:13.736205500 +0900
@@ -153,8 +153,10 @@
 	res->end = end;
 	res->flags = flags;
 
-	if (insert_resource(root, res))
+	if (insert_resource(root, res))	{
+		kfree(res);
 		return -EBUSY;
+	}
 
 	return 0;
 }
