From: Keith Owens <kaos@ocs.com.au>
Date: Sat, 27 Apr 2002 06:35:48 +0000
Subject: [Linux-ia64] ACPI without PCI
Message-Id: <marc-linux-ia64-105590701905533@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64 config.in forces CONFIG_ACPI_INTERPRETER=y but does not force
CONFIG_PCI=y.  Building 2.5.10-ia64-020426 with ACPI_INTERPRETER=y and
PCI=n gets

  drivers/acpi/acpi_osl.o: In function `acpi_os_initialize':
  drivers/acpi/acpi_osl.o(.text+0x12): undefined reference to `pcibios_config_init'
  drivers/acpi/acpi_osl.o(.text+0x20): undefined reference to `pci_config_read'
  drivers/acpi/acpi_osl.o(.text+0x22): undefined reference to `pci_config_write'
  drivers/acpi/acpi_osl.o: In function `acpi_os_read_pci_configuration':
  drivers/acpi/acpi_osl.o(.text+0x1190): undefined reference to `pci_config_read'
  drivers/acpi/acpi_osl.o(.text+0x1200): undefined reference to `pci_config_read'
  drivers/acpi/acpi_osl.o(.text+0x1270): undefined reference to `pci_config_read'
  drivers/acpi/acpi_osl.o: In function `acpi_os_write_pci_configuration':
  drivers/acpi/acpi_osl.o(.text+0x13d0): undefined reference to `pci_config_write'
  drivers/acpi/acpi_osl.o(.text+0x1440): undefined reference to `pci_config_write'
  drivers/acpi/acpi_osl.o(.text+0x14b0): undefined reference to `pci_config_write'

Either ia64 config.in must force PCI=y or acpi_osl must cope with
PCI=n.


