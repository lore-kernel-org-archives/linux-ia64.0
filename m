From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 06 Feb 2006 18:53:04 +0000
Subject: [PATCH]: Remove kfree, and fix pcidev_info struct removals
Message-Id: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove an erroneous kfree, and unlink the pcidev_info struct from the
pcidev_info list prior to free'ing the pcidev_info struct.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 2c57ee96e0e2da932adc8aa2c2ff5422456ccf3c
tree 8d2ed800415f31e4c455ccae295a8c432b7b70b4
parent 7c6c66362941df847957766ad133ff5fde67579c
author Prarit Bhargava <prarit@sgi.com> Mon, 06 Feb 2006 14:39:37 -0500
committer Prarit Bhargava <prarit@sgi.com> Mon, 06 Feb 2006 14:39:37 -0500

 arch/ia64/sn/kernel/io_init.c |    2 ++
 arch/ia64/sn/kernel/irq.c     |    4 +---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index d7e4d79..2e4e56b 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -623,6 +623,8 @@ sn_sysdata_free_start:
 	list_for_each(list, &sn_sysdata_list) {
 		element = list_entry(list, struct sysdata_el, entry);
 		list_del(&element->entry);
+		list_del(&(((struct pcidev_info *)
+			     (element->sysdata))->pdi_list));
 		kfree(element->sysdata);
 		kfree(element);
 		goto sn_sysdata_free_start;
diff --git a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
index 74d87d9..3187828 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -299,10 +299,8 @@ void sn_irq_unfixup(struct pci_dev *pci_
 		return;
 
 	sn_irq_info = SN_PCIDEV_INFO(pci_dev)->pdi_sn_irq_info;
-	if (!sn_irq_info || !sn_irq_info->irq_irq) {
-		kfree(sn_irq_info);
+	if (!sn_irq_info || !sn_irq_info->irq_irq)
 		return;
-	}
 
 	unregister_intr_pda(sn_irq_info);
 	spin_lock(&sn_irq_info_lock);
