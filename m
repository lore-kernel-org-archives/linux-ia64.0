From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Feb 2010 18:29:39 +0000
Subject: Re: [PATCH v2 0/3] pci_root: track downstream bus range for _CBA
Message-Id: <201002041129.40116.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091110170802.10645.91272.stgit@bob.kio>
In-Reply-To: <20091110170802.10645.91272.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pci@vger.kernel.org

On Tuesday 10 November 2009 10:11:28 am Bjorn Helgaas wrote:
> The PCI Firmware Spec requires BIOS to use _CBA, not MCFG, to report
> MMCONFIG regions of hot-pluggable host bridges.  Therefore, if the
> hardware and firmware support host bridge hotplug, we will encounter
> _CBA even if Linux itself doesn't support hotplug.
> 
> These patches make the pci_root driver keep track of the downstream
> bus range and make it available so arch-specific code can register
> MMCONFIG regions if necessary.

I think these patches got forgotten, but I still think they're
worthwhile.  I'd be glad to refresh them if necessary.

Bjorn
