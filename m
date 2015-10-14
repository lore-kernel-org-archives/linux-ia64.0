From: Al Stone <ahs3@redhat.com>
Date: Wed, 14 Oct 2015 21:27:43 +0000
Subject: Re: [Linaro-acpi] [PATCH v5 0/5] Provide better MADT subtable sanity checks
Message-Id: <561EC8CF.3090101@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
 <561C8351.3030304@erley.org> <561EB923.6010109@redhat.com>
 <3556673.VbpJrNsKqP@vostro.rjw.lan>
In-Reply-To: <3556673.VbpJrNsKqP@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Pat Erley <pat-lkml@erley.org>, Al Stone <al.stone@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, patches@linaro.org, Hanjun Guo <guohanjun@huawei.com>, linux-arm-kernel@lists.infradead.org

On 10/14/2015 03:25 PM, Rafael J. Wysocki wrote:
> On Wednesday, October 14, 2015 02:20:51 PM Al Stone wrote:
>> This is a multi-part message in MIME format.
>> --------------020400080004050109020606
>> Content-Type: text/plain; charset=utf-8
>> Content-Transfer-Encoding: 7bit
>>
>> On 10/12/2015 10:06 PM, Pat Erley wrote:
>>> On 10/12/2015 01:52 PM, Al Stone wrote:
>>>> On 10/11/2015 09:58 PM, Pat Erley wrote:
>>>>> On 10/11/2015 08:49 PM, Hanjun Guo wrote:
>>>>>> On 10/12/2015 11:08 AM, Pat Erley wrote:
>>>>>>> On 10/05/2015 10:12 AM, Al Stone wrote:
>>>>>>>> On 10/05/2015 07:39 AM, Rafael J. Wysocki wrote:
>>>>>>>>> On Wednesday, September 30, 2015 10:10:16 AM Al Stone wrote:
>>>>>>>>>> On 09/30/2015 03:00 AM, Hanjun Guo wrote:
>>>>>>>>>>> On 2015/9/30 7:45, Al Stone wrote:
>>>>>>>>>>>> NB: this patch set is for use against the linux-pm bleeding edge
>>>>>>>>>>>> branch.
>>>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> [snip...]
>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> For this patch set,
>>>>>>>>>>>
>>>>>>>>>>> Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
>>>>>>>>>>>
>>>>>>>>>>> Thanks
>>>>>>>>>>> Hanjun
>>>>>>>>>>
>>>>>>>>>> Thanks, Hanjun!
>>>>>>>>>
>>>>>>>>> Series applied, thanks!
>>>>>>>>>
>>>>>>>>> Rafael
>>>>>>>>>
>>>>>>>>
>>>>>>>> Thanks, Rafael!
>>>>>>>>
>>>>>>>
>>>>>>> Just decided to test out linux-next (to see the new nouveau cleanups).
>>>>>>> This change set prevents my Lenovo W510 from booting properly.
>>>>>>>
>>>>>>> Reverting: 7494b0 "ACPI: add in a bad_madt_entry() function to
>>>>>>> eventually replace the macro"
>>>>>>>
>>>>>>> Gets the system booting again.  I'm attaching my dmesg from the failed
>>>>>>> boot, who wants the acpidump?
>>>>>>
>>>>>> [    0.000000] ACPI: undefined version for either FADT 4.0 or MADT 1
>>>>>> [    0.000000] ACPI: Error parsing LAPIC address override entry
>>>>>> [    0.000000] ACPI: Invalid BIOS MADT, disabling ACPI
>>>>>>
>>>>>> Seems the MADT revision is not right, could you dump the ACPI MADT
>>>>>> (APIC) table and send it out? I will take a look :)
>>>>>>
>>>>>> Thanks
>>>>>> Hanjun
>>>>>
>>>>> Here ya go, enjoy.  Feel free to CC me on any patches that might fix it.
>>>>
>>>> Pat,
>>>>
>>>> Would you mind sending a copy of the FADT, also, please?  The first of the
>>>> ACPI messages is a check of version correspondence between the FADT and MADT,
>>>> while the second message is from looking at just an MADT subtable.  Thanks
>>>> for sending the MADT out -- that helps me quite a lot in thinking this through.
>>>>
>>>> BTW, whoever is providing the BIOS (Lenovo, I assume) may want to have a look
>>>> at these, also:
>>>>
>>>> [    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in
>>>> FADT/Pm1aControlBlock: 16/32 (20150818/tbfadt-623)
>>>> [    0.000000] ACPI BIOS Warning (bug): Invalid length for
>>>> FADT/Pm1aControlBlock: 32, using default 16 (20150818/tbfadt-704)
>>>>
>>>> Not inherently dangerous, but definitely sloppy and mind-numbingly easy to
>>>> avoid, IIRC.
>>>>
>>>
>>> Here ya go.
>>
>> Okay.  There's just a lot of weird stuff out there in ACPI-land.  I've
>> attached four minor fixes for the special cases that have been reported
>> (well, the last one is actually a fix for a typo in the spec, but just
>> the same...).
>>
>> These should apply on top of linux-next; would you mind trying them out
>> to make sure I didn't break anything else on your laptop?  If they behave
>> as I hope they will, I think I'll have covered all the places where the
>> checking of MADT subtables needs to be be relaxed a bit.  These work for
>> me on arm64, but if they work for you and a couple of other testers, then
>> I'll send them to Rafael properly.
> 
> Well, you might as well submit them properly right away, so I could pick
> them up and put them into my linux-next branch, which then might make it
> easier for some people to test them.
> 
> Thanks,
> Rafael
> 

Fair enough.  I was just being overly cautious about possible further breakage.

Done.  Patch series sent to the list.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------
