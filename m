From: Maeda Naoaki <maeda.naoaki@jp.fujitsu.com>
Date: Fri, 28 May 2004 04:06:00 +0000
Subject: Re: /proc/ioports regression in 2.6.6 on Tiger4
Message-Id: <20040528.130600.74732284.maeda@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513.182357.104026513.maeda@jp.fujitsu.com>
In-Reply-To: <20040513.182357.104026513.maeda@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,

> I have no problem with the patch, but please submit a proper changelog
> with it (together with the patch).

OK. Here you are.

This patch fixes a problem that "cat /proc/ioports" loops
on some IA64 machines that use quirk_io_region(). The problem
is caused by redundant resource claim by quirk_io_region()
and pcibios_fixup_device_resources(). The patch prevents 
this condition and is written by Matthew Wilcox.

Signed-off-by: Maeda Naoaki <maeda.naoaki@jp.fujitsu.com>

diff -urp a/arch/ia64/pci/pci.c b/arch/ia64/pci/pci.c
--- a/arch/ia64/pci/pci.c	2004-05-13 12:19:52.000000000 -0700
+++ b/arch/ia64/pci/pci.c	2004-05-13 12:21:32.000000000 -0700
@@ -323,8 +323,10 @@ pcibios_fixup_device_resources (struct p
 	struct pci_controller *controller = PCI_CONTROLLER(dev);
 	struct pci_window *window;
 	int i, j;
+	int limit = (dev->hdr_type = PCI_HEADER_TYPE_NORMAL) ? \
+		PCI_ROM_RESOURCE : PCI_NUM_RESOURCES;
 
-	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
+	for (i = 0; i < limit; i++) {
 		if (!dev->resource[i].start)
 			continue;
