From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 11 May 2016 16:57:28 +0000
Subject: Re: [PATCH v5 1/5] ACPI / processor_idle: introduce ACPI_PROCESSOR_CSTATE
Message-Id: <57336478.5050304@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462981062-24909-1-git-send-email-sudeep.holla@arm.com>
 <1462981062-24909-2-git-send-email-sudeep.holla@arm.com>
 <CAJZ5v0jQJFra6BgvNTO_jvvD-S36iDHu0B6qNkRiUzv_UhOyTQ@mail.gmail.com>
In-Reply-To: <CAJZ5v0jQJFra6BgvNTO_jvvD-S36iDHu0B6qNkRiUzv_UhOyTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Vikas Sajjan <vikas.cha.sajjan@hpe.com>, Sunil <sunil.vl@hpe.com>, Prashanth Prakash <pprakash@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, the arch/x86 maintainers <x86@kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>



On 11/05/16 17:23, Rafael J. Wysocki wrote:
> On Wed, May 11, 2016 at 5:37 PM, Sudeep Holla <sudeep.holla@arm.com> wrote:
>> ACPI 6.0 adds a new method to specify the CPU idle states(C-states)
>> called Low Power Idle(LPI) states. Since new architectures like ARM64
>> use only LPIs, introduce ACPI_PROCESSOR_CSTATE to encapsulate all the
>> code supporting the old style C-states(_CST).
>>
>> This patch will help to extend the processor_idle module to support
>> LPI.
>>
>> Cc: x86@kernel.org
>> Cc: linux-ia64@vger.kernel.org
>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
>> ---
>>   arch/ia64/Kconfig             |  1 +
>>   arch/x86/Kconfig              |  1 +
>>   drivers/acpi/Kconfig          |  4 +++
>>   drivers/acpi/processor_idle.c | 80 ++++++++++++++++++++++++++++---------------
>>   include/acpi/processor.h      |  2 +-
>>   5 files changed, 60 insertions(+), 28 deletions(-)
>>
>> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
>> index b534ebab36ea..e820670d7243 100644
>> --- a/arch/ia64/Kconfig
>> +++ b/arch/ia64/Kconfig
>> @@ -15,6 +15,7 @@ config IA64
>>          select ARCH_MIGHT_HAVE_PC_SERIO
>>          select PCI if (!IA64_HP_SIM)
>>          select ACPI if (!IA64_HP_SIM)
>> +       select ACPI_PROCESSOR_CSTATE if ACPI
>
> You don't need this ->
>
>>          select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
>>          select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
>>          select HAVE_UNSTABLE_SCHED_CLOCK
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 2dc18605831f..cb3e14757c9c 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -18,6 +18,7 @@ config X86_64
>>   config X86
>>          def_bool y
>>          select ACPI_LEGACY_TABLES_LOOKUP        if ACPI
>> +       select ACPI_PROCESSOR_CSTATE            if ACPI
>>          select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
>>          select ANON_INODES
>>          select ARCH_CLOCKSOURCE_DATA
>> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
>> index b7e2e776397d..093bfcc4f9c3 100644
>> --- a/drivers/acpi/Kconfig
>> +++ b/drivers/acpi/Kconfig
>> @@ -213,6 +213,10 @@ config ACPI_CPU_FREQ_PSS
>>          bool
>>          select THERMAL
>>
>> +config ACPI_PROCESSOR_CSTATE
>> +       bool
>
> -> if you do "def_bool y" here.
>

I agree and I did exactly the same, but then was not sure on your
preference. So dropped it :)

-- 
Regards,
Sudeep
