From: Keith Owens <kaos@ocs.com.au>
Date: Fri, 10 May 2002 05:49:07 +0000
Subject: [Linux-ia64] Re: new kernel patch (relative to 2.4.18)
Message-Id: <marc-linux-ia64-105590701905564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905563@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905563@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 May 2002 10:49:56 -0700, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>	linux-2.4.18-ia64-020508.diff.gz

Building with a minimal config.

Warnings:

arch/ia64/kernel/process.c: In function `ia64_save_extra':
arch/ia64/kernel/process.c:183: warning: implicit declaration of function `ia32_save_state'
arch/ia64/kernel/process.c: In function `ia64_load_extra':
arch/ia64/kernel/process.c:203: warning: implicit declaration of function `ia32_load_state'

mm/slab.c: In function `kmem_cache_sizes_init':
mm/slab.c:451: warning: long unsigned int format, size_t arg (arg 3)
mm/slab.c:463: warning: long unsigned int format, size_t arg (arg 3)

drivers/acpi/acpi_tables.c: In function `acpi_table_print_madt_entry':
drivers/acpi/acpi_tables.c:169: warning: long long unsigned int format, u64 arg (arg 2)
drivers/acpi/acpi_tables.c:178: warning: long long unsigned int format, u64 arg (arg 4)

CONFIG_ACPI=y, CONFIG_PCI=n still breaks.
drivers/acpi/acpi_osl.o: In function `acpi_os_initialize':
drivers/acpi/acpi_osl.o(.text+0x12): undefined reference to `pcibios_config_init'
drivers/acpi/acpi_osl.o(.text+0x20): undefined reference to `pci_config_read'
drivers/acpi/acpi_osl.o(.text+0x22): undefined reference to `pci_config_write'
drivers/acpi/acpi_osl.o: In function `acpi_os_read_pci_configuration':
drivers/acpi/acpi_osl.o(.text+0x1170): undefined reference to `pci_config_read'
drivers/acpi/acpi_osl.o(.text+0x11e0): undefined reference to `pci_config_read'
drivers/acpi/acpi_osl.o(.text+0x1250): undefined reference to `pci_config_read'
drivers/acpi/acpi_osl.o: In function `acpi_os_write_pci_configuration':
drivers/acpi/acpi_osl.o(.text+0x13b0): undefined reference to `pci_config_write'
drivers/acpi/acpi_osl.o(.text+0x1420): undefined reference to `pci_config_write'
drivers/acpi/acpi_osl.o(.text+0x1490): undefined reference to `pci_config_write'


