From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 12 Nov 2004 13:11:02 +0000
Subject: Re: [PATCH] GPE block driver [2/2]
Message-Id: <20041112131102.GE1108@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <16A54BF5D6E14E4D916CE26C9AD3057588EFB6@pdsmsx402.ccr.corp.intel.com>
In-Reply-To: <16A54BF5D6E14E4D916CE26C9AD3057588EFB6@pdsmsx402.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: Matthew Wilcox <matthew@wil.cx>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

On Fri, Nov 12, 2004 at 04:23:59PM +0800, Li, Shaohua wrote:
> Hi Matthew,
> Will you send a sequent patch? I haven't looked at an interrupt handler
> is registered for the IRQ from GPE block device.

$ cat /proc/interrupts |grep acpi
 48:          0          0          0          0          0  IO-SAPIC-level  acpi
$ sudo modprobe gpe-block
$ cat /proc/interrupts |grep acpi
 48:          0          0          0          0          0  IO-SAPIC-level  acpi
 63:          0          0          0          0          0  IO-SAPIC-level  acpi

The interrupt is registered by this call in evgpeblk.c:

$ find drivers/acpi/ -type f |xargs grep acpi_os_install_interrupt_handler
drivers/acpi/osl.c:acpi_os_install_interrupt_handler(u32 gsi, acpi_osd_handler handler, void *context)
drivers/acpi/events/evgpeblk.c:         status = acpi_os_install_interrupt_handler (interrupt_level,
drivers/acpi/events/evsci.c:    status = acpi_os_install_interrupt_handler ((u32) acpi_gbl_FADT->sci_int,

Note that up to two of the GPE blocks in the ACPI namespace may already be
registered by virtue of being in the FADT; these will not be registered
by the gpe-block driver as they don't have a _CRS method (see 9.11 of
ACPI 3.0).  I suspect 99% of the machines out there do not have additional
GPE blocks... or someone else would have written this driver by now ;-)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
