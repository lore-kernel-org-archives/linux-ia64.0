From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 30 Aug 2002 21:11:20 +0000
Subject: Re: [Linux-ia64] PCI_BUSES_TO_SCAN off by 1?
Message-Id: <marc-linux-ia64-105590701906006@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906005@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906005@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Is there any reason we don't scan the last PCI bus on IA64?
> arch/ia64/kernel/pci.c has PCI_BUSES_TO_SCAN set to 255 instead
> of 256, which prevents the kernel from scanning bus 255.  This
> causes is some problems since some of our machines (ie, the
> Itanium2 "tiger") place chipset registers in PCI config space on
> the last PCI bus.

I agree, it sounds like an off-by-one error.

Along this line, I had been hoping that if we find any PCI root
bridges via ACPI, we could skip the blind scanning of buses 0-255.
It sounds like skipping the blind scan might break tiger, though.
I assume it has root bridges in ACPI like BigSur does, but evidently
these chipset registers on bus 255 aren't found that way?  Having to
do both ACPI and blind scans feels wrong somehow, but I can't point
to a spec to back that up.

Bjorn


