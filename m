From: Colin Ngam <cngam@sgi.com>
Date: Fri, 18 Mar 2005 16:37:59 +0000
Subject: [PATCH 2.6.12 0/0] Altix only: Register Error Interrupt Handlers correctly.
Message-Id: <20050318163759.6651.84005.43068@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

The following patch ensures that the correct error interrupt handling 
routine is initialized.  This patch is based on the 2.6.12 ia64 release tree.

Please accept this patch.

Signed-off-by: Colin Ngam <cngam@sgi.com>

=== arch/ia64/sn/kernel/io_init.c 1.9 vs edited ==--- 1.9/arch/ia64/sn/kernel/io_init.c	2005-01-11 18:22:08 -06:00
+++ edited/arch/ia64/sn/kernel/io_init.c	2005-03-17 18:32:02 -06:00
@@ -142,6 +142,12 @@
 		if (status)
 			continue;
 
+		/* Attach the error interrupt handlers */
+		if (nasid & 1)
+			ice_error_init(hubdev);
+		else
+			hub_error_init(hubdev);
+
 		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++)
 			hubdev->hdi_xwidget_info[widget].xwi_hubinfo = hubdev;
 
@@ -179,10 +185,6 @@
 			    sn_flush_device_list;
 		}
 
-		if (!(i & 1))
-			hub_error_init(hubdev);
-		else
-			ice_error_init(hubdev);
 	}
 
 }
