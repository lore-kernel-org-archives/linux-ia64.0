From: John Keller <jpk@sgi.com>
Date: Tue, 15 Aug 2006 17:01:08 +0000
Subject: PCI ROM Shadowing/Copy question
Message-Id: <200608151701.k7FH18Tc194363@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net
Cc: jpk@sgi.com, ayoung@sgi.com

All,

 I'm looking for some input on how ROM shadowing
is handled in the kernel. In particular,
the case where the PROM/BIOS has shadowed the ROM
and needs to pass the shadowed copy to the kernel.

I have not seen any generic code that handles
this situation. pci_map_rom_copy() allows the kernel to
make its own copy (assumming the ROM is still readable,
which is not the case for us), but I have not seen
anything that provides for a way to pass a PROM created
ROM shadow buffer to the kernel.

Is there such a mechanism?

I've seen the thread "Ignore disabled ROM resources at setup"
that briefly touches on this...

http://marc.theaimsgroup.com/?l=linux-kernel&m2537706223050&w=2

If not, is there a preferred way of doing this?

The SN PROM shadows all valid ROM images, and the kernel 'fixup'
code, via SAL call, currently obtains these shadowed buffer addresses
and updates the pci_dev.resource[].

Along with an upcoming patch that adds base ACPI support,
and cleans up related code, we're looking to remove as much
additional 'fixup' code as possible, by having the generic
path handle as much as possible.

Should we just simply stuff our PROM address into dev->resource
and create a new IORESOURCE_ROM_BIOS_COPY flag, which will
work much the same way as IORESOURCE_ROM_COPY does, and in addition
prevent pci_cleanup_rom() from attempting to free it?

Thanks for any input,

John
jpk@sgi.com

