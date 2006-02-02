From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 02 Feb 2006 22:29:14 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F059C0791@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Do you understand why it crashes only on Altix?? It looked to
> me that all IA64 platforms would crash but obviously I'm wrong.
> What did I miss...

Not sure ... generic code in init/main.c definitely calls printk()
before it calls setup_arch(), so we should all be doomed.

On Tiger I get the following garbage, but no crash:

[417590805.377580] Linux version 2.6.16-rc1-tiger-smp (aegl@linux-t10) (gcc version 3.4.3 20050227 (Red Hat 3.4.3-22.1)) #2 SMP Thu Feb 2 14:18:45 PST 2006
[418206892.666388] EFI v1.10 by INTEL: SALsystab=0x7fe54980 ACPI=0x7ff84000 ACPI 2.0=0x7ff83000 MPS=0x7ff82000 SMBIOS=0xf0000
[662789972.910145] Initial ramdisk at: 0xe0000001fedff000 (1303562 bytes)
[662917103.942106] SAL 3.20: Intel Corp                       SR870BN4                         version 3.0
[663063150.010040] SAL Platform features: BusLock IRQ_Redirection
[663154083.057631] SAL: AP wakeup using external interrupt vector 0xf0
[1026364795.672067] No logical to physical processor mapping available
[    0.000000] iosapic_system_init: Disabling PC-AT compatible 8259 interrupts

Maybe PAL/SAL/EFI leaves some mapping in the TC for 0xffffffffffff0000 so I
don't die when reading per-cpu area?

-Tony


