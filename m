From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 29 Jul 2014 15:16:48 +0000
Subject: [PATCH 6/9] gpiolib: devres: use correct structure type name in sizeof
Message-Id: <1406647011-8543-7-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Walleij <linus.walleij@linaro.org>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br, Alexandre Courbot <gnurou@gmail.com>, linux-gpio@vger.kernel.org, linux-kernel@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/gpio/devres.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpio/devres.c b/drivers/gpio/devres.c
index 65978cf..4a63207 100644
--- a/drivers/gpio/devres.c
+++ b/drivers/gpio/devres.c
@@ -84,7 +84,7 @@ struct gpio_desc *__must_check devm_gpiod_get_index(struct device *dev,
 	struct gpio_desc **dr;
 	struct gpio_desc *desc;
 
-	dr = devres_alloc(devm_gpiod_release, sizeof(struct gpiod_desc *),
+	dr = devres_alloc(devm_gpiod_release, sizeof(struct gpio_desc *),
 			  GFP_KERNEL);
 	if (!dr)
 		return ERR_PTR(-ENOMEM);

