From: "Yu, Luming" <luming.yu@intel.com>
Date: Mon, 23 Jun 2003 07:13:18 +0000
Subject: [Linux-ia64] entry->irq = entry->link.index (problem 2 of thread [ Re: patch for updating IA64 ACPI
Message-Id: <marc-linux-ia64-105635248609013@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> @@ -248,6 +253,8 @@
>  		return_VALUE(0);
>  	}
>  
> +	entry->irq = entry->link.index;
> +
>  	if (!entry->irq && entry->link.handle) {
>  		entry->irq = acpi_pci_link_get_irq(entry->link.handle, entry->link.index);
>  		if (!entry->irq) {

> I don't quite understand what this is for.  Anyone know?

To understand the meaning of entry->link.index, please reference  acpi_get_prt  which is in arch/ia64/kernel/acpi.c.  
There is  vector[i].irq = entry->link.index , entry is acpi_prt_entry. And you can look into mp_parse_prt 
which is in arch/i386/kernel/mpparse.c. There is irq = entry->link.index.

Here,  "entry->irq = entry->link.index" just make sure that a default initial irq value is assigned according to prt entry.

Thanks,
Luming


_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64
