From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Tue, 23 Jul 2002 15:22:48 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.5.18 early printk, PCI segment, multi-IOMMU support
Message-Id: <marc-linux-ia64-105590701905817@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905804@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905804@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>   Bjorn> 60_pci_tra.diff Add support for PCI root bridges with
>   Bjorn> non-zero translation offsets.
>
> This one handles only memory offsets.  Any particular reason for this?
> Perhaps there should be at least a check which will warn/panic if a
> non-zero I/O offset is found?

Yup, there's a reason, but it's kind of lame:  I haven't figured
out how to deal with I/O offsets yet :-)  That gets into how
I/O spaces other than the legacy 64Kb space are described in
ACPI, and how the kernel accesses them.  So handling I/O
offsets will (I think) involve more extensive changes to I/O
port addressing.

-- 
Bjorn Helgaas - bjorn_helgaas at hp.com
Linux Systems Operation R&D
Hewlett-Packard Company

