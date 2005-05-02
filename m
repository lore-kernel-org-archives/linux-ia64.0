From: Prarit Bhargava <prarit@sgi.com>
Date: Mon, 02 May 2005 12:48:38 +0000
Subject: [PATCH 3/6]: SN Hotplug Driver - pci_find_next_bus export
Message-Id: <427621A6.9090102@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------000405080602050302060708"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------000405080602050302060708
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------000405080602050302060708
Content-Type: text/plain;
 name="pci_search2.patch-3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pci_search2.patch-3"

The pci_find_next_bus function is listed as being exported to drivers.  It is
not EXPORT_SYMBOL'd.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

 search.c |    1 +
 1 files changed, 1 insertion(+)

diff -urNp moved/drivers/pci/search.c pci_search/drivers/pci/search.c
--- moved/drivers/pci/search.c	2027-04-28 13:12:28.000000000 -0400
+++ pci_search/drivers/pci/search.c	2027-04-28 13:29:56.000000000 -0400
@@ -379,6 +379,7 @@ exit:				
 EXPORT_SYMBOL(pci_dev_present);
 
 EXPORT_SYMBOL(pci_find_bus);
+EXPORT_SYMBOL(pci_find_next_bus);
 EXPORT_SYMBOL(pci_find_device);
 EXPORT_SYMBOL(pci_find_device_reverse);
 EXPORT_SYMBOL(pci_find_slot);

--------------000405080602050302060708--
