From: Jes Sorensen <jes@trained-monkey.org>
Date: Mon, 20 Aug 2001 20:22:10 +0000
Subject: [Linux-ia64] Latest QLA1280 driver patch
Message-Id: <marc-linux-ia64-105590698805092@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi

I would like to announce the latest version of my patch for the QLA1280
SCSI driver.

The latest patch can be found at
http://www.trained-monkey.org/jes/linux/ the current release is 3.25.5,
relative to the driver shipped in David's 2.4.8 010815 kernel.

If someone has the opportunity to test this patch in a non ia64 box that
would be great. Unfortunately I only have access to the one qla1280 in
the ia64 box.

I have attached a list of the most significant changes I have made to
the driver so far.

Enjoy,
Jes

    Rev  3.23.5 Beta August 9, 2001, Jes Sorensen
       - Don't use SA_INTERRUPT, it's use is deprecated for this kinda driver
    Rev  3.23.4 Beta August 8, 2001, Jes Sorensen
       - Set dev->max_sectors to 1024
    Rev  3.23.3 Beta August 6, 2001, Jes Sorensen
       - Provide compat macros for pci_enable_device(), pci_find_subsys()
         and scsi_set_pci_device()
       - Call scsi_set_pci_device() for all devices
       - Reduce size of kernel version dependant device probe code
       - Move duplicate probe/init code to seperate function
       - Handle error if qla1280_mem_alloc() fails
       - Kill OFFSET() macro and use Linux's PCI definitions instead
       - Kill private structure defining PCI config space (struct config_reg)
       - Only allocate I/O port region if not in MMIO mode
       - Remove duplicate (unused) sanity check of sife of srb_t
    Rev  3.23.2 Beta August 6, 2001, Jes Sorensen
       - Change home-brew memset() implementations to use memset()
       - Remove all references to COMTRACE() - accessing a PC's COM2 serial
         port directly is not legal under Linux.
    Rev  3.23.1 Beta April 24, 2001, Jes Sorensen
       - Remove pre 2.2 kernel support
       - clean up 64 bit DMA setting to use 2.4 API (provide backwards compat)
       - Fix MMIO access to use readl/writel instead of directly
         dereferencing pointers
       - Nuke MSDOS debugging code
       - Change true/false data types to int from uint8_t
       - Use int for counters instead of uint8_t etc.
       - Clean up size & byte order conversion macro usage

