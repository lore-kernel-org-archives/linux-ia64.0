From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 28 Feb 2005 18:06:00 +0000
Subject: Badness in iosapic_unregister_intr
Message-Id: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Not sure where the problem lies on this one ...

On an hp rx4640, at shutdown of an unmodified 2.6.11-rc5 kernel, I get:

Rebooting... ACPI: PCI interrupt for device 0000:a1:04.0 disabled
iosapic_unregister_intr(4294967295) unbalanced
Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
ACPI: PCI interrupt for device 0000:a1:04.1 disabled
iosapic_unregister_intr(4294967295) unbalanced
Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
ACPI: PCI interrupt for device 0000:a1:06.0 disabled
iosapic_unregister_intr(4294967295) unbalanced
Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
ACPI: PCI interrupt for device 0000:a1:06.1 disabled
iosapic_unregister_intr(4294967295) unbalanced
Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636

Anyone else seeing it?  I wonder if it only happens for devices behind
a PCI-PCI bridge:

0000:a0:02.0 PCI bridge: IBM PCI-X to PCI-X Bridge (rev 02)
0000:a1:04.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
0000:a1:04.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
0000:a1:06.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
0000:a1:06.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
