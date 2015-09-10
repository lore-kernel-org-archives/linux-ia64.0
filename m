From: Sudeep Holla <sudeep.holla@arm.com>
Date: Thu, 10 Sep 2015 16:20:20 +0000
Subject: Re: [PATCH v2 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <55F1ADC4.7090005@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
 <1440022048-6285-2-git-send-email-al.stone@linaro.org>
 <55EDADF5.5060008@arm.com> <55F08F47.1070906@redhat.com>
In-Reply-To: <55F08F47.1070906@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <ahs3@redhat.com>, Al Stone <al.stone@linaro.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "patches@linaro.org" <patches@linaro.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>



On 09/09/15 20:57, Al Stone wrote:
> On 09/07/2015 09:32 AM, Sudeep Holla wrote:
>> Hi Al,
>>
>> On 19/08/15 23:07, Al Stone wrote:
>>
>> I finally got a chance to try this series on Juno. Well it exposed a firmware
>> bug in MADT table :)
>>
>> [..]
>>
>>>                   acpi_tbl_entry_handler handler,
>>> @@ -245,6 +484,8 @@ acpi_parse_entries(char *id, unsigned long table_size,
>>>                  table_end) {
>>>                   if (entry->type = entry_id
>>>                       && (!max_entries || count < max_entries)) {
>>> +                       if (bad_madt_entry(table_header, entry))
>>> +                               return -EINVAL;
>>
>> Not sure if we can have the above check here unconditionally.
>> Currently I can see there are 2 other users of acpi_parse_entries i.e.
>> PCC and NUMA. So may be it can be made conditional or return success for
>> non-MADT tables from bad_madt_entry ?
>
> So, I went back and double checked the other users and they're looking at
> the return value for acpi_parse_entries properly; adding in the check above
> unconditionally should not cause any behavior change.

I disagree. I populated PCCT table on Juno to get this error for
PCCT(PCCT header gets interpreted as MADT header):
"
ACPI: undefined version for either FADT 5.1 or MADT 1
Error parsing PCC subspaces from PCCT
"
And here the stacktrace:
[<ffffffc000881e58>] bad_madt_entry+0x90/0x16c
[<ffffffc000882030>] acpi_table_parse_entries+0xfc/0x180
[<ffffffc000895af8>] pcc_init+0x70/0x148

> Further, despite the name, acpi_parse_entries is only used to examine MADT
> subtables.  Granted, we should probably make the name clearer at some point
> (too ambiguous as to which entries are parsed right now).  Nonetheless, current
> usage seems to be in order.
>

 From the code inspection, I can see we have 3 users of 
acpi_parse_entries not just MADT but also PCC and NUMA/SRAT

Something like this solves this issue:
-              if (bad_madt_entry(table_header, entry))
+              if (!strncmp(id, ACPI_SIG_MADT, 4) &&
+                      bad_madt_entry(table_header, entry)


Or am I still missing something ?

Regards,
Sudeep
