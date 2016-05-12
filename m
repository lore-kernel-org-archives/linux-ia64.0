From: Sudeep Holla <sudeep.holla@arm.com>
Date: Thu, 12 May 2016 09:10:56 +0000
Subject: Re: [PATCH v5 1/5] ACPI / processor_idle: introduce ACPI_PROCESSOR_CSTATE
Message-Id: <573448A0.5030003@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462981062-24909-1-git-send-email-sudeep.holla@arm.com>
 <1462981062-24909-2-git-send-email-sudeep.holla@arm.com>
 <CAJvTdKnJPZ9Nfib=CqBczMP4BERqfqAzeSR-+jjFOGZR51oVmg@mail.gmail.com>
 <CAJvTdKmTykoMBw9dCpw0X0ep2qTPSu94-zzUmdrFwUfDeXueqA@mail.gmail.com>
In-Reply-To: <CAJvTdKmTykoMBw9dCpw0X0ep2qTPSu94-zzUmdrFwUfDeXueqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux acpi <linux-acpi@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vikas Sajjan <vikas.cha.sajjan@hpe.com>, Sunil <sunil.vl@hpe.com>, Prashanth Prakash <pprakash@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, X86 ML <x86@kernel.org>, linux-ia64@vger.kernel.org

(I seem to have 2 emails, replying on the second)

On 11/05/16 19:28, Len Brown wrote:
> What is the functional goal/purpose of adding CONFIG_ACPI_PROCESSOR_CSTATE?
>

Avoid adding unnecessary dummy implementations of functions and
variables that will never be used on ARM64 and also looks ugly IMO. 
E.g.:	arch_safe_halt
	boot_option_idle_override
	IDLE_NOMWAIT
	acpi_unlazy_tlb
	acpi_processor_cstate_check
	disabled_by_idle_boot_param and more...

> If the answer is that it saves code space on an ARM build, how much
> space does it save?
>

NO, it doesn't even add a kB of code I believe, so that's definitely not
the reason. I am fine to retain if we can find a saner way to solve the
above issue.

-- 
Regards,
Sudeep
