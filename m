From: Andi Kleen <ak@suse.de>
Date: Mon, 17 May 2004 15:41:19 +0000
Subject: Re: [PATCH] ACPI PCI IRQ routing rework
Message-Id: <20040517174119.64d134b0.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200405151120.45753.bjorn.helgaas@hp.com>
In-Reply-To: <200405151120.45753.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: acpi-devel@lists.sourceforge.net, len.brown@intel.com, davidm@hpl.hp.com, jun.nakajima@intel.com, linux-ia64@vger.kernel.org

On Sat, 15 May 2004 11:20:45 -0600
Bjorn Helgaas <bjorn.helgaas@hp.com> wrote:

> I think it's better to pull all the PRT knowledge out of the arch
> code and do the IRQ allocation and IO-APIC programming at the time
> of pci_enable_device().  That reduces IRQ usage (since many PRT
> entries are never used) and is a step toward allowing the addition
> of new root bridges and PRTs at run-time.

I like this change very much. It should make PRT misrouting problems 
easier to debug, because the system will be already up and running
then (at least with modular drivers). 

Also things that are not needed are not configured and that reduces
the potential for bugs.

-Andi
