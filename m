From: Sudeep Holla <sudeep.holla@arm.com>
Date: Mon, 22 Feb 2016 13:46:26 +0000
Subject: Re: [PATCH v3 4/5] ACPI / processor_idle : introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
Message-Id: <56CB1132.1060202@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
 <1449065446-26115-5-git-send-email-sudeep.holla@arm.com>
 <12469811.iv3SctjXxl@vostro.rjw.lan> <56C465CE.50403@arm.com>
In-Reply-To: <56C465CE.50403@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>

Hi Rafael,

On 17/02/16 12:21, Sudeep Holla wrote:
>
>
> On 16/02/16 20:18, Rafael J. Wysocki wrote:

[..]

>
>> This way it all should work without any new Kconfig options.
>>
>
> I agree with you in terms of avoiding new Kconfig option. However the
> main reason for adding it is to avoid declaring dummy functions and
> variables on ARM64.
>
> It's hard to justify the maintainers as it's totally useless on ARM64.
> E.g. boot_option_idle_override, IDLE_NOMWAIT, acpi_unlazy_tlb,
> arch_safe_halt.
>
> Other option is to push those under CONFIG_X86, but then I don't have
> much idea on what are all needed for IA64, so took an option that
> encapsulates everything under CSTATE feature Kconfig, which is not user
> visible and selected by archs supporting it by default.
>
> I am open to any other alternative.
>

Whatever alternative methods I tried so far ended up much horrible than
this. So any suggestions are much appreciated.

-- 
Regards,
Sudeep
