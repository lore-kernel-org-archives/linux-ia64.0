From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Tue, 29 Jul 2014 15:16:47 +0000
Subject: [PATCH 5/9] scsi: use correct structure type name in sizeof
Message-Id: <1406647011-8543-6-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dario Ballabio <ballabio_dario@emc.com>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org, ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br, "James E.J. Bottomley" <JBottomley@parallels.com>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/scsi/eata.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/eata.c b/drivers/scsi/eata.c
index 813dd5c..4caf221 100644
--- a/drivers/scsi/eata.c
+++ b/drivers/scsi/eata.c
@@ -811,7 +811,7 @@ struct mscp {
 	struct sg_list *sglist;	/* pointer to the allocated SG list */
 };
 
-#define CP_TAIL_SIZE (sizeof(struct sglist *) + sizeof(dma_addr_t))
+#define CP_TAIL_SIZE (sizeof(struct sg_list *) + sizeof(dma_addr_t))
 
 struct hostdata {
 	struct mscp cp[MAX_MAILBOXES];	/* Mailboxes for this board */

