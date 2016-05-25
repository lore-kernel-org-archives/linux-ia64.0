From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 25 May 2016 14:42:26 +0000
Subject: Re: [PATCH v7 13/15] ACPI / processor: Add acpi_map_madt_entry().
Message-Id: <20160525144225.GF5996@e104818-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
 <1464129345-18985-14-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-14-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

On Tue, May 24, 2016 at 03:35:43PM -0700, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
> 
> Follow-on arm64 ACPI/NUMA patches need to map MADT entries very early
> (before kmalloc is usable).
> 
> Add acpi_map_madt_entry() which, indirectly, uses
> early_memremap()/early_memunmap() to access the table and parse out
> the mpidr.  The existing implementation of map_madt_entry() is
> modified to take a pointer to the MADT as a parameter and the callers
> adjusted.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
