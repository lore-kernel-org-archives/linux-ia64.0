From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 11 May 2016 09:12:29 +0000
Subject: Re: [PATCH v6 07/14] arm64, numa: Cleanup NUMA disabled messages.
Message-Id: <20160511091229.GB3051@e104818-lin.cambridge.arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
 <1461780436-27182-8-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461780436-27182-8-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

On Wed, Apr 27, 2016 at 11:07:09AM -0700, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
> 
> As noted by Dennis Chen, we don't want to print "No NUMA configuration
> found" if NUMA was forced off from the command line.
> 
> Change the type of numa_off to bool, and clean up printing code.
> Print "NUMA disabled" if forced off on command line and "No NUMA
> configuration found" if there was no firmware NUMA information.
> 
> Signed-off-by: David Daney <david.daney@cavium.com>

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
