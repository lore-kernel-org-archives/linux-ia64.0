From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 23 Jun 2003 18:27:56 +0000
Subject: Re: [Linux-ia64] entry->irq = entry->link.index (problem 2 of thread [ Re: patch for updating IA64 A
Message-Id: <marc-linux-ia64-105639307615971@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105635248609013@msgid-missing>
In-Reply-To: <marc-linux-ia64-105635248609013@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 23 Jun 2003 15:13:18 +0800, "Yu, Luming" <luming.yu@intel.com> said:

  >> @@ -248,6 +253,8 @@
  >> return_VALUE(0);
  >> }

  >> +	entry->irq = entry->link.index;
  >> +
  >> if (!entry->irq && entry->link.handle) {
  entry-> irq = acpi_pci_link_get_irq(entry->link.handle, entry->link.index);
  >> if (!entry->irq) {

  >> I don't quite understand what this is for.  Anyone know?

  Luming> To understand the meaning of entry->link.index, please
  Luming> reference acpi_get_prt which is in arch/ia64/kernel/acpi.c.
  Luming> There is vector[i].irq = entry->link.index , entry is
  Luming> acpi_prt_entry. And you can look into mp_parse_prt which is
  Luming> in arch/i386/kernel/mpparse.c. There is irq   Luming> entry->link.index.

Ah, that's where x86 is doing the transformation.  Thanks for finding
that.  I didn't understand how the old code worked on x86.

Can we do the transformation at the same time on both platforms?
Obviously there is no mpparse.c but perhaps arch/ia64/kernel/acpi.c
could do it.  I wonder though if this scheme would work with hotplug
devices.

In any case, whatever the solution, we clearly should use the same
approach on both platforms.

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
