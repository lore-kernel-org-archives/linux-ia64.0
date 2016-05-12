From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 12 May 2016 16:24:49 +0000
Subject: Re: [PATCH v6 13/14] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <20160512162449.GK11226@e104818-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
 <1461780436-27182-14-git-send-email-ddaney.cavm@gmail.com>
 <20160511103929.GC3051@e104818-lin.cambridge.arm.com>
 <5733C8F5.6090206@caviumnetworks.com>
 <20160512094915.GD11226@e104818-lin.cambridge.arm.com>
 <5734A0CC.8010600@caviumnetworks.com>
In-Reply-To: <5734A0CC.8010600@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney@caviumnetworks.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, David Daney <david.daney@cavium.com>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Frank Rowand <frowand.list@gmail.com>, x86@kernel.org, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Grant Likely <grant.likely@linaro.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, Jon Masters <jcm@redhat.com>, Robert Richter <rrichter@cavium.com>, Rob Herring <robh+dt@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, devel@acpica.org, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, Hanjun Guo <hanjun.guo@linaro.org>, Ganapatrao Kulkarni <gkulkarni@caviumnetwor>

On Thu, May 12, 2016 at 08:27:08AM -0700, David Daney wrote:
> On 05/12/2016 02:49 AM, Catalin Marinas wrote:
> >On Wed, May 11, 2016 at 05:06:13PM -0700, David Daney wrote:
> >>On 05/11/2016 03:39 AM, Catalin Marinas wrote:
> [...]
> >>>
> >>>I wonder whether you could replace the get_mpidr_in_madt() function with
> >>>something like acpi_get_phys_id(). It looks like get_mpidr_in_madt()
> >>>duplicates functionality already available elsewhere.
> >>
> >>I just tried that, and it doesn't work.
> >>
> >>The problem is that this code is being run very early in the boot, and
> >>kmalloc cannot be used.  acpi_get_phys_id() and its ilk can only be used
> >>once we have working kmalloc.  We need to extract the NUMA information early
> >>like this precisely because it is needed to initializing the slab system
> >>
> >>Notice that we are using early_acpi_os_unmap_memory() et al. in
> >>get_mpidr_in_madt() explicitly for this reason.
> >>
> >>In summary: I don't think we need another revision of this patch, it is like
> >>this for a good reason.
> >
> >Slightly confusing, in another reply you said you are going to address
> >my comment. So, is it doable?
> 
> I don't think so.
> 
> My previous reply, to the thread in 0/14, was prematurely made with the
> incorrect assumption that it was a simple change.  Now, after really digging
> in to the code, and attempting to do as you suggested, I have changed my
> mind.

Would the snippet below help with avoiding any kmalloc calls? At a quick
look, it seems that it's only map_mat_entry() that ends up using
kmalloc() calls. Alternatively, exporting map_madt_entry() may work as
well.

diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index 33a38d604630..77af0a7df914 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -152,6 +152,9 @@ static phys_cpuid_t map_mat_entry(acpi_handle handle, int type, u32 acpi_id)
 	struct acpi_subtable_header *header;
 	phys_cpuid_t phys_id = PHYS_CPUID_INVALID;
 
+	if (!acpi_gbl_permanent_mmap)
+		return phys_id;
+
 	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_MAT", NULL, &buffer)))
 		goto exit;
 

-- 
Catalin
