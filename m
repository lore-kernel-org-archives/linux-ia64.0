From: "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>
Date: Thu, 04 Aug 2005 22:34:10 +0000
Subject: RE: [patch] fix ACPI table discovery from EFI for x86
Message-Id: <D36CE1FCEFD3524B81CA12C6FE5BCAB00A9F04AD@fmsmsx406.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200507140109.j6E19a58013012@snoqualmie.dp.intel.com>
In-Reply-To: <200507140109.j6E19a58013012@snoqualmie.dp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, "Brown, Len" <len.brown@intel.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

Bjorn Helgaas <> wrote:
> On Wednesday 13 July 2005 7:09 pm, Matt Tolentino wrote:
>> This patch addresses a problem on x86 EFI systems with larger memory
>> configurations.  Up until now, we've relied on the fact that the
>> ACPI RSDT would reside somewhere in low memory that could be
>> permanently 
>> mapped in kernel address space - so __va() has been sufficient. 
>> However, 
>> on EFI systems, the RSDT is often anywhere in the lower 4GB of
>> physical 
>> address space.  So, we may need to remap it on x86 systems.
> 
> The hunk below breaks HP rx7620, rx8620, and Superdome (all ia64)
> systems.  This is from 2.6.13-rc4-mm1, in

Ugh.  Well, that's pretty ugly...

Andrew, Len, please drop this one until I look at this closer.  

>     acpi-fix-table-discovery-from-efi-for-x86.patch

Thanks for testing Bjorn.  

matt 

 
