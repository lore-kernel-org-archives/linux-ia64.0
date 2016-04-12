From: Sudeep Holla <sudeep.holla@arm.com>
Date: Tue, 12 Apr 2016 14:29:42 +0000
Subject: Re: [PATCH v3 5/5] ACPI / processor_idle: Add support for Low Power Idle(LPI) states
Message-Id: <570D0656.1000608@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com>
 <1449065446-26115-6-git-send-email-sudeep.holla@arm.com>
 <CAGm_ybhENGdNCUQw3OPb7XN+kLVdeyugTq+Py0iMNP-v3rGBsg@mail.gmail.com>
In-Reply-To: <CAGm_ybhENGdNCUQw3OPb7XN+kLVdeyugTq+Py0iMNP-v3rGBsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vikas Sajjan <sajjan.linux@gmail.com>
Cc: Sudeep Holla <sudeep.holla@arm.com>, linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>, Vikas C Sajjan <vikas.cha.sajjan@hpe.com>, Sunil V L <sunil.vl@hpe.com>



On 12/04/16 05:06, Vikas Sajjan wrote:
> Hi Sudeep,
>
>
> On Wed, Dec 2, 2015 at 7:40 PM, Sudeep Holla <sudeep.holla@arm.com> wrote:

[...]

>> diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
>> index 29f787b2493f..bfc59de0ce6b 100644
>> --- a/drivers/acpi/processor_driver.c
>> +++ b/drivers/acpi/processor_driver.c
>> @@ -90,7 +90,7 @@ static void acpi_processor_notify(acpi_handle handle, u32 event, void *data)
>>                                                    pr->performance_platform_limit);
>>                  break;
>>          case ACPI_PROCESSOR_NOTIFY_POWER:
>> -               acpi_processor_cst_has_changed(pr);
>> +               acpi_processor_power_state_has_changed(pr);
>
> The function  acpi_processor_power_state_has_changed() has a check as below,
>
>   if (nocst)
>             return -ENODEV;
>
> So was wondering if the platform supports only _LPI and  _CST is not
> supported, the 'nocst' module param passed will be 1,
> and function will return -ENODEV.
>

You are right, it needs to be handled correctly. Thanks for spotting this.

> Hence, with the introduction of LPI, should we be handling "nocst"
> appropriately.
> Similar is the case in function  int acpi_processor_hotplug(struct
> acpi_processor *pr);
>

Correct.

> Let me know, if i am missing something here.
>

I don't think so. Once again thanks for the review.

-- 
Regards,
Sudeep
