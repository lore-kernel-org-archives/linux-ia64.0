From: Prarit Bhargava <prarit@sgi.com>
Date: Tue, 07 Feb 2006 20:31:49 +0000
Subject: [PATCH]: Minor cleanup of sn_bus_free_sysdata
Message-Id: <20060207203127.20095.46850.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Small cleanup for misuse of list_for_each to list_for_each_safe.

This patch was suggested by Kenneth W. Chen here, and depends on the patch
in that discussion:
http://marc.theaimsgroup.com/?l=linux-ia64&m3929797803776&w=2

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit eb9f45aec29f8c25f5a55dd0b4af9b6bf94cef7f
tree d6a9cc6af919ef006633579e9eaf81b04e0ffd18
parent 2f251784f604791190b89cb07df7672c73fa6832
author Prarit Bhargava <prarit@sgi.com> Tue, 07 Feb 2006 16:23:10 -0500
committer Prarit Bhargava <prarit@sgi.com> Tue, 07 Feb 2006 16:23:10 -0500

 arch/ia64/sn/kernel/io_init.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 2e4e56b..3437c23 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -617,17 +617,15 @@ void sn_bus_store_sysdata(struct pci_dev
 void sn_bus_free_sysdata(void)
 {
 	struct sysdata_el *element;
-	struct list_head *list;
+	struct list_head *list, *safe;
 
-sn_sysdata_free_start:
-	list_for_each(list, &sn_sysdata_list) {
+	list_for_each_safe(list, safe, &sn_sysdata_list) {
 		element = list_entry(list, struct sysdata_el, entry);
 		list_del(&element->entry);
 		list_del(&(((struct pcidev_info *)
 			     (element->sysdata))->pdi_list));
 		kfree(element->sysdata);
 		kfree(element);
-		goto sn_sysdata_free_start;
 	}
 	return;
 }
