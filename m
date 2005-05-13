From: Prarit Bhargava <prarit@sgi.com>
Date: Fri, 13 May 2005 00:45:53 +0000
Subject: [PATCH 3/6]: hotplug/ia64: SN Hotplug Driver - pci_find_next_bus export
Message-Id: <20050513004551.17135.32873.sendpatchset@prarit.boston.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42835E79.5040209@sgi.com>
In-Reply-To: <42835E79.5040209@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The pci_find_next_bus function is listed as being exported to drivers.  It is
not EXPORT_SYMBOL'd.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit b1fcf8446e48103abd7521df7024036d0b877735
tree 3a3b6bc7d6665ede97ab69549f9f82675bf8b9e4
parent 5c2b591a316b5d728d6cf16b9f44960319c37ff9
author Prarit Bhargava <prarit@sgi.com> 1810126521 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810126521 -0400

Index: drivers/pci/search.c
=================================--- 609461315376faf97b95c8fded1d5df433168614/drivers/pci/search.c  (mode:100644 sha1:a90a533eba0fc3f8c7b1b892c4d0b2b4fc159730)
+++ 3a3b6bc7d6665ede97ab69549f9f82675bf8b9e4/drivers/pci/search.c  (mode:100644 sha1:05fa91a31c620b0dd9de57a59066ed6adae71062)
@@ -379,6 +379,7 @@
 EXPORT_SYMBOL(pci_dev_present);
 
 EXPORT_SYMBOL(pci_find_bus);
+EXPORT_SYMBOL(pci_find_next_bus);
 EXPORT_SYMBOL(pci_find_device);
 EXPORT_SYMBOL(pci_find_device_reverse);
 EXPORT_SYMBOL(pci_find_slot);
