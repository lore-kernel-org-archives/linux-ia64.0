From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 17 Sep 2002 23:09:55 +0000
Subject: [Linux-ia64] Re: 2.4.19 ACPI build errors
Message-Id: <marc-linux-ia64-105590701906034@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> iosapic.c:529: `ACPI_INTERRUPT_PMI' undeclared (first use in this function)
...
> The config looks like:
> CONFIG_ACPI20=y
> CONFIG_ACPI_KERNEL_CONFIG=y
> CONFIG_ACPI=y
> CONFIG_ACPI_INTERPRETER=y

You need CONFIG_ACPI_BOOT as well.  CONFIG_ACPI20 is mentioned
in Documentation/Configure.help but nowhere else, so you don't need
that.  arch/ia64/defconfig contains several other ACPI options; I don't
know whether you can build a working ia64 kernel with them turned
off.

Bjorn


