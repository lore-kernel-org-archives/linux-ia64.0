From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 12 Nov 2003 06:02:47 +0000
Subject: Building 2.6.0-test9 without ACPI
Message-Id: <marc-linux-ia64-106861699532525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

My zx2000 keeps hitting a MCA seemingly the moment it gets to the
login: prompt, sometimes during boot with test9.

To try and debug I went to turn ACPI off in menuconfig, but it doesn't
seem to actually turn ACPI off properly.  The sub-menu doesn't
disappear as you would expect (and as happens when configuring an x86)
and trying to build ends up with

arch/ia64/kernel/iosapic.c: In function `iosapic_set_affinity':
arch/ia64/kernel/iosapic.c:290: warning: comparison is always false due to limited range of data type
arch/ia64/kernel/iosapic.c: In function `iosapic_register_platform_intr':
arch/ia64/kernel/iosapic.c:530: error: `ACPI_INTERRUPT_PMI' undeclared (first use in this function)
arch/ia64/kernel/iosapic.c:530: error: (Each undeclared identifier is reported only once
arch/ia64/kernel/iosapic.c:530: error: for each function it appears in.)
arch/ia64/kernel/iosapic.c:539: error: `ACPI_INTERRUPT_INIT' undeclared (first use in this function)
arch/ia64/kernel/iosapic.c:543: error: `ACPI_INTERRUPT_CPEI' undeclared (first use in this function)
make[1]: *** [arch/ia64/kernel/iosapic.o] Error 1

I think this is because all sorts of things are left in the config
that maybe shouldn't be there?

# CONFIG_ACPI is not set
CONFIG_ACPI_EFI=y
CONFIG_ACPI_INTERPRETER=y
CONFIG_ACPI_KERNEL_CONFIG=y

I had a look in drivers/acpi/Kconfig and things look mostly right to
me (ACPI_INTERPRETER depends on ACPI, everything else depends on
ACPI_INTERPRETER).  Is it just me?

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au
