From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 29 Jul 2014 15:16:43 +0000
Subject: [PATCH 1/9] drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c: use correct structure type name in
Message-Id: <1406647011-8543-2-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mauro Carvalho Chehab <m.chehab@samsung.com>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-media@vger.kernel.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c b/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c
index cda8388..255590f 100644
--- a/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c
+++ b/drivers/staging/media/davinci_vpfe/vpfe_mc_capture.c
@@ -227,7 +227,7 @@ static int vpfe_enable_clock(struct vpfe_device *vpfe_dev)
 		return 0;
 
 	vpfe_dev->clks = kzalloc(vpfe_cfg->num_clocks *
-				   sizeof(struct clock *), GFP_KERNEL);
+				   sizeof(struct clk *), GFP_KERNEL);
 	if (vpfe_dev->clks = NULL) {
 		v4l2_err(vpfe_dev->pdev->driver, "Memory allocation failed\n");
 		return -ENOMEM;

