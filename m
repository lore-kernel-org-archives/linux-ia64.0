From: Colin Ngam <cngam@sgi.com>
Date: Mon, 20 Aug 2001 13:52:55 +0000
Subject: [Linux-ia64] Experiences during Intel Interop in June 2001
Message-Id: <marc-linux-ia64-105590698805089@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I was at the Intel Interop for IA64 in San Diego, June 2001, representing SGI with our SNIA-64 system.  While working
with the various vendors(PCI Devices), I noted the following:

1.  64-Bits DMA Capable Drivers should advertise it's capability to the kernel

During PCI discovery, the DMA capability of the driver/card is by default
set to "0xffffffff".  This is done in the routine:

        static struct pci_dev * __init pci_scan_device(struct pci_dev *temp) {

                ....

                dev->dma_mask = 0xffffffff;

                ....

        }

It is the responsibility of the drivers themselves to reset this value
to match it's capability.

Not resetting this value on an IA64 machine can result in performance
penalties.

Drivers can use:

        int pci_set_dma_mask(struct pci_dev *dev, dma_addr_t mask)

to set the dma_mask to an appropriate value.


2.  64 bit capable DMA Addresses

On IA64, a translated DMA address is defined as:

        typedef u64 dma_addr_t

This is a 64 bits value.  Drivers should not assume that any/part of the
dma_addr_t bits are insignificant(not used).  On IA64 architecture like SNIA(
SGI IA-64 Architecture), all 64 bits are used.  For example, this architecture
uses bits 63 .. 56 of the DMA Handles to inform the DMA Engine the characteristics
of this particular DMA transfer e.g. PREFETCH, DMA Port to use etc.

We have observed drivers with 64 bits DMA capabilities sending only 32bits of
the dma_addr_t to the controller card.  This will definitely work on IA32
platforms, even on "some" IA64 platforms if the memory range is =< 32bits.

Translated DMA addresses are 64bits unless your driver cannot support 64 bits
DMA addresses.

We do support 32 bits DMA addresses, but for a 64 bits DMA capable driver, all 64 bits of the DMA address is relevent.


3.  PCI Space Config Registers - Base Address Registers

On IA64 platform, it is probably no longer appropriate for drivers to read
and use the values as initialized in the Base Address Registers(PCI).  These
values may only be pertinent to that particular PCI bus.  That is, that's
the address on that PCI bus that the card will latch onto, but not necessary,
the same address(value) that the driver uses in the kernel(IN/OUT macros).

Drivers should always use the values from the "struct pci_dev":

        struct pci_dev {

                ...
        /*
         * Instead of touching interrupt line and base address registers
         * directly, use the values stored here. They might be different!
         */
                unsigned int    irq;
                struct resource resource[DEVICE_COUNT_RESOURCE]; /* I/O and memory regions + expansion ROMs */
                struct resource dma_resource[DEVICE_COUNT_DMA];
                struct resource irq_resource[DEVICE_COUNT_IRQ];

                ...
        }

Please take note that these IO and Memory resources values are unsigned 64
bits. I/O Resource range is not neccessary only 16bits(0-65K).  On IA64
platforms like SNIA-64 from SGI, I/O Resource can be greater that 65K.  This
may mean that legacy in/out instructions will not be able to take advantage
of the greater IO Resource values, however, IA64 drivers using any of the
in/out macros, with the "port" value as defined "unsigned long port" will
enjoy wider accessiblity.

Comments?

Thanks.

Colin



