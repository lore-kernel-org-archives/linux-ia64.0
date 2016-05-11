From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 11 May 2016 15:07:56 +0000
Subject: Re: [PATCH v4 1/5] ACPI / processor_idle: introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
Message-Id: <57334ACC.2000403@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461069013-13292-1-git-send-email-sudeep.holla@arm.com>
 <1461069013-13292-2-git-send-email-sudeep.holla@arm.com>
 <5796685.UTMTWTestt@vostro.rjw.lan>
In-Reply-To: <5796685.UTMTWTestt@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Al Stone <al.stone@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, x86@kernel.org, linux-ia64@vger.kernel.org



On 10/05/16 01:02, Rafael J. Wysocki wrote:
> On Tuesday, April 19, 2016 01:30:09 PM Sudeep Holla wrote:
>> ACPI 6.0 adds a new method to specify the CPU idle states(C-states)
>> called Low Power Idle(LPI) states. Since new architectures like ARM64
>> use only LPIs, introduce ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE to
>> encapsulate all the code supporting the old style C-states(_CST)
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
>>   drivers/acpi/Kconfig          |  3 ++
>>   drivers/acpi/processor_idle.c | 74 +++++++++++++++++++++++++++++--------------
>>   include/acpi/processor.h      |  3 +-
>>   5 files changed, 57 insertions(+), 25 deletions(-)
>>
>> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
>> index b534ebab36ea..717de2a146e2 100644
>> --- a/arch/ia64/Kconfig
>> +++ b/arch/ia64/Kconfig
>> @@ -16,6 +16,7 @@ config IA64
>>   	select PCI if (!IA64_HP_SIM)
>>   	select ACPI if (!IA64_HP_SIM)
>>   	select ACPI_SYSTEM_POWER_STATES_SUPPORT if ACPI
>> +	select ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE if ACPI
>>   	select ARCH_MIGHT_HAVE_ACPI_PDC if ACPI
>>   	select HAVE_UNSTABLE_SCHED_CLOCK
>>   	select HAVE_IDE
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index 2dc18605831f..eb03fd0d63b9 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -37,6 +37,7 @@ config X86
>>   	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
>>   	select ARCH_MIGHT_HAVE_PC_PARPORT
>>   	select ARCH_MIGHT_HAVE_PC_SERIO
>> +	select ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE if ACPI
>>   	select ARCH_SUPPORTS_ATOMIC_RMW
>>   	select ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT
>>   	select ARCH_SUPPORTS_INT128		if X86_64
>> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
>> index 82b96ee8624c..ec289078667c 100644
>> --- a/drivers/acpi/Kconfig
>> +++ b/drivers/acpi/Kconfig
>> @@ -48,6 +48,9 @@ config ACPI_LEGACY_TABLES_LOOKUP
>>   config ARCH_MIGHT_HAVE_ACPI_PDC
>>   	bool
>>
>> +config ARCH_SUPPORTS_ACPI_PROCESSOR_CSTATE
>> +	bool
>
> It might be better to do
>
> config ACPI_PROCESSOR_CST
> 	bool
> 	depends on ia64 || x86
>

Done

> Should it depend on ARCH_HAS_POWER_INIT too?
>

IIUC it's not defined for ia64, so better not to add that dependency
here IMO. include/acpi/processor.h encapsulates it. Let me know if I
have misunderstood it.

-- 
Regards,
Sudeep
