From: Matt_Domsch@Dell.com
Date: Tue, 14 Nov 2000 04:39:16 +0000
Subject: RE: [Linux-ia64] Simple Question Simple Answer
Message-Id: <marc-linux-ia64-105590678205719@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205701@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205701@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Allow me to pass on some words of wisdom I received from Alan Cox a while
back.  Particularly for IA-64, the comment to use the new PCI DMA
architecture (linux/Documentatation/DMA-mapping.txt) has become especially
important, as >4GB systems will be fairly common, and many drivers I've seen
(as of September) were limiting system memory to 4GB because they hadn't
migrated to this yet.

Thanks,
Matt



   Alan Cox porting notes   6/12/2000 
The 2.2 to 2.4 porting should be easy. The big points are:

Remember to use pci_enable_device

dev->base_address[foo]. is now dev->resource[foo].start
and does not need masking for the flag bits

cli()/sti() type locking is now right out. In 2.2 its bad in 2.4 its
very very bad 8)

Use the new scsi error handling  - it really is a big win handling
degrading setups.

The scsi proc has changed

If its a PCI irq allocate using SA_SHIRQ but you must now pass
something other than NULL for the dev_id


If you want it to work on stuff like ia64 it needs to be both 64bit clean
and touch mmio space only using readb/readw/readl etc not by direct pointer
references.

If you want it to work with >4Gb of RAM you really want to use the new
pci_alloc_consistent API - but I would worry about that once it works
not before.

Alan
 

