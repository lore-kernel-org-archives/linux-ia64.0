From: Sudeep Holla <sudeep.holla@arm.com>
Date: Wed, 17 Feb 2016 12:03:05 +0000
Subject: Re: [PATCH v3 2/5] ACPI / sleep: move acpi_processor_sleep to sleep.c
Message-Id: <56C46179.2040806@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
 <1449065446-26115-3-git-send-email-sudeep.holla@arm.com>
 <2288656.HghHDFBFlP@vostro.rjw.lan>
In-Reply-To: <2288656.HghHDFBFlP@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>



On 16/02/16 20:13, Rafael J. Wysocki wrote:
> On Wednesday, December 02, 2015 02:10:43 PM Sudeep Holla wrote:
>> acpi_processor_sleep is neither related nor used by CPUIdle framework.
>> It's used in system suspend/resume path as a syscore operation. It makes
>> more sense to move it to acpi/sleep.c where all the S-state transition
>> (a.k.a. Linux system suspend/hiberate) related code are present.
>>
>> Also make it depend on CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT so that
>> it's not compiled on architecture like ARM64 where S-states are not
>> yet defined in ACPI.
>>
>> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
>> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>
>
> To me this goes in the right direction, but I'd take it a bit further.
>
>> ---
>>   drivers/acpi/processor_driver.c |  2 --
>>   drivers/acpi/processor_idle.c   | 37 -------------------------------------
>>   drivers/acpi/sleep.c            | 35 +++++++++++++++++++++++++++++++++++
>>   include/acpi/processor.h        |  8 --------
>>   4 files changed, 35 insertions(+), 47 deletions(-)
>>

[...]

>> @@ -677,6 +678,39 @@ static void acpi_sleep_suspend_setup(void)
>>   static inline void acpi_sleep_suspend_setup(void) {}
>>   #endif /* !CONFIG_SUSPEND */
>>
>> +#ifdef CONFIG_PM_SLEEP
>> +static u32 saved_bm_rld;
>> +
>> +static int acpi_processor_suspend(void)
>
> Why do we need mention processor in the function name here (and below)?
>
> I'd call it something like acpi_save/restore_bm_rld() (maybe with a short comment
> explaining what the BM RLD is).
>

Sure, I had thought so initially and wanted to do that in a separate
patch for easy of review but totally forgot later. Thanks for pointing
it out. Updated patch on it's way.

-- 
Regards,
Sudeep
