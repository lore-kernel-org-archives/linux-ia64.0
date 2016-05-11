From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 11 May 2016 10:40:14 +0000
Subject: Re: [PATCH v6 14/14] acpi, numa: Enable ACPI based NUMA on ARM64
Message-Id: <20160511104014.GD3051@e104818-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
 <1461780436-27182-15-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461780436-27182-15-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

On Wed, Apr 27, 2016 at 11:07:16AM -0700, David Daney wrote:
> From: Hanjun Guo <hanjun.guo@linaro.org>
> 
> Add function needed for cpu to node mapping, and enable ACPI based
> NUMA for ARM64 in Kconfig
> 
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> Signed-off-by: Robert Richter <rrichter@cavium.com>
> [david.daney@cavium.com added ACPI_NUMA default to y for ARM64]
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
