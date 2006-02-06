From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 06 Feb 2006 19:47:40 +0000
Subject: Re: [PATCH]: Remove kfree, and fix pcidev_info struct removals
Message-Id: <43E7A7DC.90200@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030500060505070909040702"
List-Id: <linux-ia64.vger.kernel.org>
References: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
In-Reply-To: <20060206185244.12145.74416.sendpatchset@prarit.boston.redhat.com>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030500060505070909040702
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

New patch.

--------------030500060505070909040702
Content-Type: text/plain;
 name="hpfix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hpfix.patch"

Two Hotplug driver related fixes in the SN ia64 code.

Remove an erroneous kfree, and unlink the pcidev_info struct from the
pcidev_info list prior to free'ing the pcidev_info struct.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit 1ad024b793f5f1aa1cf098a19430298e2a66bc40
tree 4c269432f9b58145a39fd65bcbc671f23b4c83c8
parent 7c6c66362941df847957766ad133ff5fde67579c
author Prarit Bhargava <prarit@sgi.com> Mon, 06 Feb 2006 15:38:47 -0500
committer Prarit Bhargava <prarit@sgi.com> Mon, 06 Feb 2006 15:38:47 -0500

 arch/ia64/sn/kernel/io_init.c |    2 ++
 arch/ia64/sn/kernel/irq.c     |    4 +++-
 2 files changed, 5 insertions(+), 1 deletions(-)

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
index 74d87d9..c373113 100644
--- a/arch/ia64/sn/kernel/irq.c
+++ b/arch/ia64/sn/kernel/irq.c
@@ -299,7 +299,9 @@ void sn_irq_unfixup(struct pci_dev *pci_
 		return;
 
 	sn_irq_info = SN_PCIDEV_INFO(pci_dev)->pdi_sn_irq_info;
-	if (!sn_irq_info || !sn_irq_info->irq_irq) {
+	if (!sn_irq_info)
+		return;
+	if (!sn_irq_info->irq_irq) {
 		kfree(sn_irq_info);
 		return;
 	}

--------------030500060505070909040702--
