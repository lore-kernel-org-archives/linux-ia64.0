From: Herbert Poetzl <herbert@13thfloor.at>
Date: Sun, 31 Oct 2004 01:51:25 +0000
Subject: [Bug] required .config ACPI_NUMA not selected by NUMA + ACPI
Message-Id: <20041031015125.GA13908@mail.13thfloor.at>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


greetings!

probably already known and maybe already fixed

the config option CONFIG_ACPI_NUMA is required 
when CONFIG_NUMA and  CONFIG_ACPI are set for 
the kernel to compile, but it isn't forced by 
the Kconfig (the default is N) ...

not setting it leads to:

  CC      arch/ia64/kernel/acpi.o
arch/ia64/kernel/acpi.c: In function `acpi_map_iosapic':
arch/ia64/kernel/acpi.c:704: error: `MAX_PXM_DOMAINS' undeclared (first use in this function)
arch/ia64/kernel/acpi.c:704: error: (Each undeclared identifier is reported only once
arch/ia64/kernel/acpi.c:704: error: for each function it appears in.)
arch/ia64/kernel/acpi.c:709: error: `pxm_to_nid_map' undeclared (first use in this function)
make[1]: *** [arch/ia64/kernel/acpi.o] Error 1
make: *** [arch/ia64/kernel] Error 2


note: I'm not subscribed to the linux-ia64 ml
and I do not use or own an ia64 so I'm just 
reporting this for the unlikely case that it
might be of some use ...

best,
Herbert

