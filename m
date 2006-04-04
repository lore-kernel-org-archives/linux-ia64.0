From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 04 Apr 2006 23:38:51 +0000
Subject: Re: 2.6.17-rc1-mm1
Message-Id: <20060404233851.GA6411@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060404014504.564bf45a.akpm@osdl.org>
In-Reply-To: <20060404014504.564bf45a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, Apr 04, 2006 at 01:45:04AM -0700, Andrew Morton wrote:
> - VGA on ia64 is broken - the screen comes up blank.  But ia64 otherwise
>   seems to work OK.  I didn't have time to investigate.

Broken in base 2.6.17-rc1 too :-(  VGA comes up and prints a
few messages, and then goes wonky and dies.  Comparing
what I _think_ I saw with the dmesg output, it appears to
die here:

[    6.416740] ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 18 (level, low) -> IRQ 48
[    6.708439] e1000: 0000:01:00.0: e1000_probe: (PCI:33MHz:32-bit) 00:03:47:fd:bb:42
[    6.754439] e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
[    6.761547] netconsole: not configured, aborting
[    6.766195] initcall at 0xa0000001007c4c30: init_netconsole+0x0/0x140(): returned with error code -22
[    6.775520] Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2

    DEAD DEAD DEAD

Should have gone on to say:
[    6.781924] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[    6.790052] ICH4: IDE controller at PCI slot 0000:00:1f.1
[    6.795513] PCI: Device 0000:00:1f.1 not available because of resource collisions
[    6.803100] ACPI: PCI Interrupt 0000:00:1f.1[A]: no GSI
[    6.808403] ICH4: BIOS configuration fixed.
[    6.812646] ICH4: chipset revision 1
[    6.816271] ICH4: not 100% native mode: will probe irqs later


But I might be off by a line or two, the last bit flashed by quite quickly.

I'll start bisecting tomorrow to see when it was broken.

-Tony
