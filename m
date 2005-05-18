From: Prarit Bhargava <prarit@sgi.com>
Date: Wed, 18 May 2005 13:41:04 +0000
Subject: Re: [Pcihpd-discuss] Re: [PATCH 3/6]: hotplug/ia64: SN Hotplug Driver
Message-Id: <428B45F0.6060002@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030000030404050807090109"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030000030404050807090109
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Greg KH wrote:
> On Thu, May 12, 2005 at 08:45:53PM -0400, Prarit Bhargava wrote:
> 
>>+EXPORT_SYMBOL(pci_find_next_bus);
> 
> 
> EXPORT_SYMBOL_GPL() please.
> 
> greg k-h
> 


--------------030000030404050807090109
Content-Type: text/plain;
 name="pci_search.patch-3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pci_search.patch-3"

The pci_find_next_bus function is listed as being exported to drivers.  It is
not EXPORT_SYMBOL_GPL'd.

Signed-off-by: Prarit Bhargava <prarit@sgi.com>

---
commit e294c434e2b07cd37bd92c4400ddc038bd1fb095
tree 0074994b061b33a65ec96ee3a8058c4025162add
parent efa92797b1020a20adb4c0b045026b5b096d18aa
author Prarit Bhargava <prarit@sgi.com> 1810556612 -0400
committer Prarit Bhargava <prarit@sgi.com> 1810556612 -0400

Index: drivers/pci/search.c
===================================================================
--- 5dfad6510087f1d4f1a791920aafb924a855e5a2/drivers/pci/search.c  (mode:100644 sha1:a90a533eba0fc3f8c7b1b892c4d0b2b4fc159730)
+++ 0074994b061b33a65ec96ee3a8058c4025162add/drivers/pci/search.c  (mode:100644 sha1:11d450ab995e25838e36f34c067eb60006c8395a)
@@ -379,6 +379,7 @@
 EXPORT_SYMBOL(pci_dev_present);
 
 EXPORT_SYMBOL(pci_find_bus);
+EXPORT_SYMBOL_GPL(pci_find_next_bus);
 EXPORT_SYMBOL(pci_find_device);
 EXPORT_SYMBOL(pci_find_device_reverse);
 EXPORT_SYMBOL(pci_find_slot);

--------------030000030404050807090109--
