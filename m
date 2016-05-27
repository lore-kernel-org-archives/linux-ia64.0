From: Dennis Chen <dennis.chen@linaro.org>
Date: Fri, 27 May 2016 08:04:22 +0000
Subject: Re: [PATCH v7 14/15] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <CADKHWaeyWjagdW-T1GTFRwvXrVUpb3oLaa5qOimhd247Lk5gQg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com> <1464129345-18985-15-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-15-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, David Daney <d>

On 25 May 2016 at 06:35, David Daney <ddaney.cavm@gmail.com> wrote:
> From: Hanjun Guo <hanjun.guo@linaro.org>
>
> Introduce a new file to hold ACPI based NUMA information parsing from
> SRAT and SLIT.
>
> SRAT includes the CPU ACPI ID to Proximity Domain mappings and memory
> ranges to Proximity Domain mapping.  SLIT has the information of inter
> node distances(relative number for access latency).
>
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> Signed-off-by: Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>
> [rrichter@cavium.com Reworked for numa v10 series ]
> Signed-off-by: Robert Richter <rrichter@cavium.com>
> [david.daney@cavium.com reorderd and combinded with other patches in
> Hanjun Guo's original set, removed get_mpidr_in_madt() and use
> acpi_map_madt_entry() instead.]
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---

I've tested this patch on Juno board with home made SRAT and SLIT
table, so feel free to add:
Tested-by: Dennis Chen <dennis.chen@arm.com>

-- 
Regards,
Dennis
