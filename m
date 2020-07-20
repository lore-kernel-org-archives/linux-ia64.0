From: Hanjun Guo <guohanjun@huawei.com>
Date: Mon, 20 Jul 2020 02:02:42 +0000
Subject: Re: [PATCH v2 0/6] ACPI: Only create NUMA nodes from entries in SRAT or SRAT emulation.
Message-Id: <9b679614-083b-cec4-e0de-34e1a66b103a@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200717175959.899775-1-Jonathan.Cameron@huawei.com>
In-Reply-To: <20200717175959.899775-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jonathan Cameron <Jonathan.Cameron@huawei.com>, linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, martin@geanix.com, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, linuxarm@huawei.com, Dan Williams <dan.j.williams@intel.com>, Song Bao Hua <song.bao.hua@hisilicon.com>

On 2020/7/18 1:59, Jonathan Cameron wrote:
> Here, I will use the term Proximity Domains for the ACPI description and
> NUMA Nodes for the in kernel representation.
> 
> ACPI 6.3 included a clarification that only Static Resource Allocation
> Structures in SRAT may define the existence of proximity domains
> (sec 5.2.16). This clarification closed a possible interpretation that
> other parts of ACPI (e.g. DSDT _PXM, NFIT etc) could define new proximity
> domains that were not also mentioned in SRAT structures.
> 
> In practice the kernel has never allowed this alternative interpretation as
> such nodes are only partially initialized. This is architecture specific
> but to take an example, on x86 alloc_node_data has not been called.
> Any use of them for node specific allocation, will result in a crash as the
> infrastructure to fallback to a node with memory is not setup.
> 
> We ran into a problem when enabling _PXM handling for PCI devices and found
> there were boards out there advertising devices in proximity domains that
> didn't exist [2].
> 
> The fix suggested in this series is to replace instances that should not
> 'create' new nodes with pxm_to_node.  This function needs a some additional
> hardening against invalid inputs to make sure it is safe for use in these
> new callers.
> 
> Patch 1 Hardens pxm_to_node() against numa_off, and pxm entry being too large.
> 
> Patch 2-4 change the various callers not related to SRAT entries so that they
> set this parameter to false, so do not attempt to initialize a new NUMA node
> if the relevant one does not already exist.
> 
> Patch 5 is a function rename to reflect change in functionality of
> acpi_map_pxm_to_online_node() as it no longer creates a new map, but just does a
> lookup of existing maps.
> 
> Patch 6 covers the one place we do not allow the full flexibility defined
> in the ACPI spec.  For SRAT GIC Interrupt Translation Service (ITS) Affinity
> Structures, on ARM64, the driver currently makes an additional pass of SRAT
> later in the boot than the one used to identify NUMA domains.
> Note, this currently means that an ITS placed in a proximity domain that is
> not defined by another SRAT structure will result in the a crash.
> 
> To avoid this crash with minimal changes we do not create new NUMA nodes based
> on this particular entry type.  Any current platform trying to do this will not
> boot, so this is an improvement, if perhaps not a perfect solution.

Make sense to me,

Reviewed-by: Hanjun Guo <guohanjun@huawei.com>
