From: "Li, Shaohua" <shaohua.li@intel.com>
Date: Thu, 20 Jan 2005 02:53:03 +0000
Subject: RE: [Pcihpd-discuss] [PATCH] Convert acpiphp to use generic resource code
Message-Id: <16A54BF5D6E14E4D916CE26C9AD3057501060A68@pdsmsx402.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050119183853.C12618@unix-os.sc.intel.com>
In-Reply-To: <20050119183853.C12618@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This patch converts acpiphp to use the generic PCI resource assignment
>code.  It's quite large, but most of it is deleting the acpiphp_pci and
>acpiphp_res files.  It's tested on an hp Integrity rx8620 (which won't
>work without this patch).  Testers with other hardware welcomed.
>
>If you're testing on ia64, you'll probably need two other patches as
well:
>
>http://marc.theaimsgroup.com/?l=linux-ia64&m0614534704894&w=2
>
>and this one (already sent to Greg):
Hi,
Should we make the count of pci_bus's resource dynamically? Root
bridge's BAR isn't standard, I'm afraid ACPI will report more than
'PCI_BUS_NUM_RESOURCES' BARs.

Thanks,
Shaohua
