From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 06 Sep 2001 07:16:13 +0000
Subject: [Linux-ia64] drivers/acpi/Makefile, CONFIG_ACPI_KERNEL_CONFIG
Message-Id: <marc-linux-ia64-105590698805129@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linus's 2.4.9, drivers/acpi/Makefile has

ifdef CONFIG_ACPI_KERNEL_CONFIG
   obj-$(CONFIG_ACPI)   += acpiconf.o osconf.o 
else

The IA64 patch has

ifdef CONFIG_ACPI_KERNEL_CONFIG
   obj-$(CONFIG_ACPI)   += acpiconf.o osconf.o driver.o
else

Any reason the trailing driver.o is missing from Linus's kernel?


