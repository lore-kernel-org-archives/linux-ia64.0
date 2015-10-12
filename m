From: Al Stone <ahs3@redhat.com>
Date: Mon, 12 Oct 2015 19:07:31 +0000
Subject: Re: [Linaro-acpi] [PATCH v5 0/5] Provide better MADT subtable sanity checks
Message-Id: <561C04F3.2010507@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
 <561B5B7E.6080901@linaro.org> <561B8114.4060800@arm.com>
 <32835486.gnkKHR2R1U@vostro.rjw.lan>
In-Reply-To: <32835486.gnkKHR2R1U@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Sudeep Holla <sudeep.holla@arm.com>
Cc: Hanjun Guo <hanjun.guo@linaro.org>, Pat Erley <pat-lkml@erley.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org, linux-acpi@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>, linux-arm-kernel@lists.infradead.org

On 10/12/2015 01:25 PM, Rafael J. Wysocki wrote:
> On Monday, October 12, 2015 10:44:52 AM Sudeep Holla wrote:
>>
>> On 12/10/15 08:04, Hanjun Guo wrote:
>>> On 10/12/2015 11:58 AM, Pat Erley wrote:
>>>> On 10/11/2015 08:49 PM, Hanjun Guo wrote:
>>>>> On 10/12/2015 11:08 AM, Pat Erley wrote:
>>>>>> On 10/05/2015 10:12 AM, Al Stone wrote:
>>>>>>> On 10/05/2015 07:39 AM, Rafael J. Wysocki wrote:
>>>>>>>> On Wednesday, September 30, 2015 10:10:16 AM Al Stone wrote:
>>>>>>>>> On 09/30/2015 03:00 AM, Hanjun Guo wrote:
>>>>>>>>>> On 2015/9/30 7:45, Al Stone wrote:
>>>>>>>>>>> NB: this patch set is for use against the linux-pm bleeding edge
>>>>>>>>>>> branch.
>>>>>>>>>>>
>>>>>>>>>
>>>>>>>>> [snip...]
>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> For this patch set,
>>>>>>>>>>
>>>>>>>>>> Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
>>>>>>>>>>
>>>>>>>>>> Thanks
>>>>>>>>>> Hanjun
>>>>>>>>>
>>>>>>>>> Thanks, Hanjun!
>>>>>>>>
>>>>>>>> Series applied, thanks!
>>>>>>>>
>>>>>>>> Rafael
>>>>>>>>
>>>>>>>
>>>>>>> Thanks, Rafael!
>>>>>>>
>>>>>>
>>>>>> Just decided to test out linux-next (to see the new nouveau cleanups).
>>>>>> This change set prevents my Lenovo W510 from booting properly.
>>>>>>
>>>>>> Reverting: 7494b0 "ACPI: add in a bad_madt_entry() function to
>>>>>> eventually replace the macro"
>>>>>>
>>>>>> Gets the system booting again.  I'm attaching my dmesg from the failed
>>>>>> boot, who wants the acpidump?

Thanks for sending this!

>>>>> [    0.000000] ACPI: undefined version for either FADT 4.0 or MADT 1
>>>>> [    0.000000] ACPI: Error parsing LAPIC address override entry
>>>>> [    0.000000] ACPI: Invalid BIOS MADT, disabling ACPI
>>>>>
>>>>> Seems the MADT revision is not right, could you dump the ACPI MADT
>>>>> (APIC) table and send it out? I will take a look :)
>>>>>
>>>>> Thanks
>>>>> Hanjun
>>>>
>>>> Here ya go, enjoy.  Feel free to CC me on any patches that might fix it.
>>>
>>> Thanks! I think I had the right guess, the MADT revision is not right
>>> for ACPI 4.0:
>>>
>>> [000h 0000   4]                    Signature : "APIC"    [Multiple APIC
>>> Description Table (MADT)]
>>> [004h 0004   4]                 Table Length : 000000BC
>>> [008h 0008   1]                     *Revision : 01*
>>>
>>> I encountered such problem before because the table was just copied from
>>> previous version, and without the update for table revision.
>>>
>>> I think we may need to ignore the table revision for x86, but restrict
>>> it for ARM64, I'd like Al and Rafael's suggestion before I send out a
>>> patch.
>>>
>>
>> Instead of just removing the check completely on x86, IMO restrict it to
>> some newer/later version of ACPI so you can still force vendors to fix
>> their ACPI tables at-least in future.
> 
> No, we can't force vendors to fix their ACPI tables.  This is completely
> unrealistic.
> 
> We simly need to deal with the bugs in the ACPI tables in the kernel.

Unfortunately true.  I've had a couple of reports to look at and think
through apart from this; it's really quite fascinating how much stuff
a slightly stricter table check is turning up.  A little surprising,
too, but fascinating.  A fix is in progress, still needs some testing...

>> It would be good to get such sanity check in the tools used to build
>> those tables, but yes since such static tables can be built in many
>> ways, its difficult to deal it in all those tools.
> 
> As I said to Al, we need those checks in firmware test suites.  Having
> them in the kernel is OK too, but they should cause warnings to be printed
> to the kernel log instead of causing the kernel to panic.
> 
> Thanks,
> Rafael
> 

Yup.  Agreed.  For x86, we can't induce kernel panics.  Since arm64 is new to
the game, we'll be stricter since we can afford to be for now.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------
