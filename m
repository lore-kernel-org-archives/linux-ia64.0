From: colin ngam <cngam@sgi.com>
Date: Tue, 09 Aug 2005 20:27:35 +0000
Subject: Re: IA-64 : Map PCI Bar into user virtual space from Physical address
Message-Id: <42F911B7.103@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42F25A72.7030603@ireq.ca>
In-Reply-To: <42F25A72.7030603@ireq.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Frangois Guay wrote:

> I'm working to build a linux kernel module for a PCI card to run on 
> SGI Altix IA-64
>
> I'm using Kernel 2.6.5-7.145-rt IA-64
>
> I have read the Linux Device Driver Programmers's - Guide - Porting to 
> SGI Altix Systems, 007-4520-005
>
> I'm using a Linux software package from PLX version 4.4 for linux 2.6
> http://www.plxtech.com/products/tools/software/default.asp
>
> I load the module in the kernel
> In the user side, I have a program to open the device, map the device
>
> My problem actually is that I can not access the Bar[2] address in my 
> user program after mapped this Bar in my user memory, the PCI Bar[2] 
> memory region
>
> This is what I'm doing to map the memory :
>
> 1- In the kernel module, the function pci_ressource_start return an 
> address for Bar[2] :  0xc00000080fa00000
> I can access these address in the kernel and print data or whatever.
> The real physical address in the Bar[2] is 0x400000 but I read in the 
> SGI manual that I can not use these address.
>
> 2- My user program ask the Linux Kernel Module to map these Bar[2] in 
> the user memory so the kernel return a user address 0x2000000000500000 
> mapped for the user program
> You can see the output in the kernel Mapped Physical address 
> 0xc00000080fa00000 => User space 0x2000000000500000

Remove 0xc when you do the mapping in your driver.

Thanks.

colin

>
> 3- When I try to access (RD) these 0x2000000000500000 address, the 
> Altix is not responding!
>
> The module support IOCTL calls and works very good
>
> So this is my problem!
>
> Thank you for your help!
>
> Regards
>
>
> This is my PCI register
> -------------------------------------------------------------------------
> PCI Registers:
>  0x000: 40713c5  Device ID|Vendor ID
>  0x004: 2800007  Status|Command
>  0x008: ff000000  Base Class|Sub Class|Interface|Revision ID
>  0x00c: 2000  BIST|Header Type|Latency Timer|Cache Line Size
>  0x010: 200000  PCI Base Address 0 for Memory Mapped Runtime Regs
>  0x014: 200001  PCI Base Address 1 for I/O Mapped Runtime Regs
>  0x018: 400000  PCI Base Address 2 for Local Address Space 0
>  0x01c: 1000000  PCI Base Address 3 for Local Address Space 1
>  0x020: 0  PCI Base Address 4 for Local Address Space 2
>  0x024: 0  PCI Base Address 5 for Local Address Space 3
>  0x028: 0  Cardbus CIS Pointer
>  0x02c: 40713c5  Subsystem ID|Subsystem Vendor ID
>  0x030: 0  PCI Base Address to Local Expansion ROM
>  0x034: 0  Reserved
>  0x038: 0  Reserved
>  0x03c: 13f  Max_Lat|Min_Grant|Interrupt Pin|Interrupt Line
>
> lspci -v
> -------------------------------------------------------------------------
> 0000:02:02.0 Class ff00: Alphi Technology Corp: Unknown device 0407
>        Subsystem: Alphi Technology Corp: Unknown device 0407
>        Flags: bus master, medium devsel, latency 32, IRQ 63
>        Memory at c00000080fe00000 (32-bit, non-prefetchable) [size2M]
>        I/O ports at c00000080fc00000 [size%6]
>        Memory at c00000080fa00000 (32-bit, non-prefetchable) [size=2M]
>        Memory at c0000008a1000000 (32-bit, non-prefetchable) [sizeM]
>        Expansion ROM at 0000000000000800 [disabled]
>
>
> printk output module
> -------------------------------------------------------------------------
>
> <7>Pci9080: Received message => OPEN_DEVICE
> <7>Pci9080: Opening Management interface...
> <7>Pci9080: ...device opened
>
> PLX_IOCTL_PCI_DEVICE_FIND
>
> <7>Pci9080: Received message => CLOSE_DEVICE
> <7>Pci9080: Closing Management interface...
> <7>Pci9080: ...device closed
>
> <7>Pci9080: Received message => OPEN_DEVICE
> <7>Pci9080: Opening Management interface...
> <7>Pci9080: ...device opened
>
> PLX_IOCTL_PCI_DEVICE_FIND
>
> <7>Pci9080: Received message => CLOSE_DEVICE
> <7>Pci9080: Closing Management interface...
> <7>Pci9080: ...device closed
>
> <7>Pci9080: Received message => OPEN_DEVICE
> <7>Pci9080: Opening Management interface...
> <7>Pci9080: ...device opened
>
> PLX_IOCTL_PCI_DEVICE_FIND
>
> <7>Pci9080: Received message => CLOSE_DEVICE
> <7>Pci9080: Closing Management interface...
> <7>Pci9080: ...device closed
>
> <7>Pci9080: Received message => OPEN_DEVICE
> <7>Pci9080: Opening device (Pci9080-0)...
> <7>Pci9080: Dispatch spin_lock...
> <7>Pci9080:    StartDevice
> <7>Pci9080:    Resource 00
> <7>Pci9080:      Physical.QuadPart  : c00000080fe00000
> <7>Pci9080:      Type     : Memory Space
> <7>Pci9080:      Address  : c00000080fe00000
> <7>Pci9080:      Size     : 100  (256 bytes)
> <7>Pci9080:      PCI BAR  : 0
> <7>Pci9080:  Request memory region
> <7>Pci9080:  Get a kernel-mapped virtual address ioremap
> <7>Pci9080:      Kernel VA: c00000080fe00000
> <7>Pci9080:    Resource 01
> <7>Pci9080:      Physical.QuadPart  : c00000080fc00000
> <7>Pci9080:      Type     : I/O Port
> <7>Pci9080:      Address  : c00000080fc00000
> <7>Pci9080:      Size     : 100  (256 bytes)
> <7>Pci9080:      PCI BAR  : 1
> <7>Pci9080:  Request I/O port region
> <7>Pci9080:    Resource 02
> <7>Pci9080:      Physical.QuadPart  : c00000080fa00000
> <7>Pci9080:     Physical Bar 2[0] = 0
> <7>Pci9080:     Physical Bar 2[4] = 0
> <7>Pci9080:     Physical Bar 2[8] = 0
> <7>Pci9080:     Physical Bar 2[12] = 0
> <7>Pci9080:     Physical Bar 2[16] = 0
> <7>Pci9080:     Physical Bar 2[20] = 0
> <7>Pci9080:     Physical Bar 2[24] = 0
> <7>Pci9080:     Physical Bar 2[28] = 0
> <7>Pci9080:      Type     : Memory Space
> <7>Pci9080:      Address  : c00000080fa00000
> <7>Pci9080:      Size     : 200000  (2048 Kb)
> <7>Pci9080:      PCI BAR  : 2
> <7>Pci9080:  Request memory region
> <7>Pci9080:  Get a kernel-mapped virtual address ioremap
> <7>Pci9080:      Kernel VA: c00000080fa00000
> <7>Pci9080:    Resource 03
> <7>Pci9080:      Physical.QuadPart  : c0000008a1000000
> <7>Pci9080:      Type     : Memory Space
> <7>Pci9080:      Address  : c0000008a1000000
> <7>Pci9080:      Size     : 1000000  (16384 Kb)
> <7>Pci9080:      PCI BAR  : 3
> <7>Pci9080:  Request memory region
> <7>Pci9080:  Get a kernel-mapped virtual address ioremap
> <7>Pci9080:      Kernel VA: c0000008a1000000
> <7>Pci9080: Disable the PCI interrupt...
> <7>Pci9080: ...device opened
>
> PLX_IOCTL_DRIVER_VERSION
>
> PLX_IOCTL_DEVICE_INIT
>
> PLX_IOCTL_CHIP_TYPE_GET
>
> PLX_IOCTL_PCI_BAR_RANGE_GET
>
> PLX_IOCTL_PCI_BAR_GET
>
> <7>Pci9080: Received message ==> MMAP
> <7>Pci9080: Added map object (0x713bfc80) to list
> <7>Pci9080: ...Completed message
>
> PLX_IOCTL_PHYSICAL_MEM_MAP
> <7>Pci9080: Found and removed map object (0xe0000030713bfc80) from list
> <7>Pci9080:  Plx_io_remap_page_range ...
> <7>Pci9080: Mapped Physical address (0xc00000080fe00000) => User 
> space (0x2000000000400000)
>
> PLX_IOCTL_PCI_BAR_RANGE_GET
>
> PLX_IOCTL_PCI_BAR_GET
>
> PLX_IOCTL_PCI_BAR_RANGE_GET
>
> PLX_IOCTL_PCI_BAR_GET
>
> <7>Pci9080: Received message ==> MMAP
> <7>Pci9080: Added map object (0x713bfc80) to list
> <7>Pci9080: ...Completed message
>
> PLX_IOCTL_PHYSICAL_MEM_MAP
> <7>Pci9080: Found and removed map object (0xe0000030713bfc80) from list
> <7>Pci9080:  Plx_io_remap_page_range ...
> <7>Pci9080: Mapped Physical address (0xc00000080fa00000) => User 
> space (0x2000000000500000)
>
> PLX_IOCTL_PCI_BAR_RANGE_GET
>
> PLX_IOCTL_PCI_BAR_GET
>
> <7>Pci9080: Received message ==> MMAP
> <7>Pci9080: Added map object (0x713bfc80) to list
> <7>Pci9080: ...Completed message
>
> PLX_IOCTL_PHYSICAL_MEM_MAP
> <7>Pci9080: Found and removed map object (0xe0000030713bfc80) from list
> <7>Pci9080:  Plx_io_remap_page_range ...
> <7>Pci9080: Mapped Physical address (0xc0000008a1000000) => User 
> space (0x2000000000700000)
>
> PLX_IOCTL_PCI_BAR_RANGE_GET
>
> PLX_IOCTL_PCI_BAR_RANGE_GET
>
>
>

