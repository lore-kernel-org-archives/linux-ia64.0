From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 17 Feb 2016 12:21:34 +0000
Subject: Re: [PATCH v3 4/5] ACPI / processor_idle : introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
Message-Id: <56C465CE.50403@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
 <1449065446-26115-5-git-send-email-sudeep.holla@arm.com>
 <12469811.iv3SctjXxl@vostro.rjw.lan>
In-Reply-To: <12469811.iv3SctjXxl@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>



On 16/02/16 20:18, Rafael J. Wysocki wrote:
> On Wednesday, December 02, 2015 02:10:45 PM Sudeep Holla wrote:
>> ACPI 6.0 adds a new method to specify the CPU idle states(C-states)
>> called Low Power Idle(LPI) states. Since new architectures like ARM64
>> use only LPIs, introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE to
>> encapsulate all the code supporting the old style C-states(_CST)
>
> No.
>
> The way it really should work is to check if the firmware supports LPI
> (and what kind of it) and try to use _CST if LPI is not supported.
>

Agreed

> If LPI is supported by the firmware, use it if the LPI objects are
> present as expected or fall back to using _CST otherwise.
>

I have something similar but I need to reverse the order I think.

> This way it all should work without any new Kconfig options.
>

I agree with you in terms of avoiding new Kconfig option. However the
main reason for adding it is to avoid declaring dummy functions and
variables on ARM64.

It's hard to justify the maintainers as it's totally useless on ARM64.
E.g. boot_option_idle_override, IDLE_NOMWAIT, acpi_unlazy_tlb,
arch_safe_halt.

Other option is to push those under CONFIG_X86, but then I don't have
much idea on what are all needed for IA64, so took an option that
encapsulates everything under CSTATE feature Kconfig, which is not user
visible and selected by archs supporting it by default.

I am open to any other alternative.

-- 
Regards,
Sudeep
