From: Matthew Wilcox <willy@debian.org>
Date: Fri, 03 Sep 2004 19:33:54 +0000
Subject: [PATCH] acpiphp misc fixes [5/5]
Message-Id: <20040903193354.GT642@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040903193027.GO642@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040903193027.GO642@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Greg KH <greg@kroah.com>, pcihpd-discuss@lists.sourceforge.net, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


Two minor fixes:

 - Correct the docbook (parameter renamed to value)
 - If a resource is 64-bit, the debug code was previously truncating its value.

diff -urpNX build-tools/dontdiff linux-2.6/drivers/pci/hotplug/acpiphp_core.c hotplug-2.6/drivers/pci/hotplug/acpiphp_core.c
--- linux-2.6/drivers/pci/hotplug/acpiphp_core.c	2004-05-23 17:52:23.000000000 -0600
+++ hotplug-2.6/drivers/pci/hotplug/acpiphp_core.c	2004-09-03 08:09:15.181670908 -0600
@@ -210,8 +212,7 @@ static int get_adapter_status(struct hot
 /**
  * get_address - get pci address of a slot
  * @hotplug_slot: slot to get status
- * @busdev: pointer to struct pci_busdev (seg, bus, dev)
- *
+ * @value: pointer to struct pci_busdev (seg, bus, dev)
  */
 static int get_address(struct hotplug_slot *hotplug_slot, u32 *value)
 {
diff -urpNX build-tools/dontdiff linux-2.6/drivers/pci/hotplug/acpiphp_res.c hotplug-2.6/drivers/pci/hotplug/acpiphp_res.c
--- linux-2.6/drivers/pci/hotplug/acpiphp_res.c	2004-05-23 17:52:23.000000000 -0600
+++ hotplug-2.6/drivers/pci/hotplug/acpiphp_res.c	2004-09-02 10:51:54.000000000 -0600
@@ -669,8 +669,8 @@ static void dump_resource(struct pci_res
 	cnt = 0;
 
 	while (p) {
-		dbg("[%02d] %08x - %08x\n",
-		    cnt++, (u32)p->base, (u32)p->base + p->length - 1);
+		dbg("[%02d] 0x%llx - 0x%llx\n", cnt++, (long long)p->base,
+				(long long)(p->base + p->length - 1));
 		p = p->next;
 	}
 }

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
