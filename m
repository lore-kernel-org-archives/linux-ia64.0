From: "Lee, Jung-Ik" <jung-ik.lee@intel.com>
Date: Thu, 24 Oct 2002 16:37:50 +0000
Subject: [Linux-ia64] RE: PCI Hotplug Drivers for 2.5
Message-Id: <marc-linux-ia64-105590709805230@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805223@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805223@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> I think we now all agree that resource management should move into a
> place where it can be shared by all pci hotplug drivers, right?
> 
> If so, anyone want to propose some common code?  I think the stuff in
> the ACPI driver that was pulled from the Compaq driver is a 
> great start.
> I can try to pull this into the core myself, but if the Intel 
> developers
> have the time, and energy, I would greatly appreciate their help (or
> anyone else who wants to join in.)
> 

Resource Management code in phprm.h works fine for both ACPI based platforms
and non-ACPI platforms (smbios, BIOS $HRT, pcibios_pci_irq_routing...) doing
php enumeration, configuration, resource allocation, etc. Only phprm_acpi.c
is included in this release for size matters.
intcphp driver is free from controller type, IA32/IPF, ACPI/non-ACPI and
depending on kernel configuration, it can bind to either ACPI PHPRM or
non-ACPI PHPRM.

PCI resource handling code - that does add/delete/sort/combine, etc on
pci_resource - has nothing to do with ACPI or non-ACPI so it should be
common across cpqphp, ibmphp, acpiphp and intcphp. They are duplicated and
varied due to mother structures differences.

> thanks,
> 
> greg k-h
> 

