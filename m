From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 14 Mar 2006 23:59:49 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <200603141659.49535.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
In-Reply-To: <200602021946.k12Jk446028921@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, "Moore, Robert" <robert.moore@intel.com>, Thomas Renninger <trenn@suse.de>

On Thursday 02 February 2006 12:46, Luck, Tony wrote:
> Booting a snapshot of Linus' tree this morning I saw a few (new?)
> kernel unaligned access warnings:
> 
> ACPI: Subsystem revision 20060127
> ACPI: Interpreter enabled
> ACPI: Using IOSAPIC for interrupt routing
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> kernel unaligned access to 0xe00000407ec5a204, ip=0xa0000001003af8c0
> kernel unaligned access to 0xe00000407ec5a23c, ip=0xa0000001003af8c0
> kernel unaligned access to 0xe00000407ec5a28c, ip=0xa0000001003af8c0
> kernel unaligned access to 0xe00000407ec5a1fc, ip=0xa0000001003ae6c1
> kernel unaligned access to 0xe00000407ec5a204, ip=0xa0000001003ae6d1
> ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
> ACPI: PCI Root Bridge [PCI1] (0000:20)

Did we ever resolve this?  Are we just waiting for new ACPI bits
to trickle into -mm and mainline?

I'd like to see the patch for just this issue, because it affects
SLES10, and Novell might balk at a complete ACPI CA update, but
might take just the individual patch.

Bjorn
