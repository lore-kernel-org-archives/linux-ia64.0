From: Al Stone <ahs3@redhat.com>
Date: Thu, 10 Sep 2015 20:43:45 +0000
Subject: Re: [PATCH v2 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <55F1EB81.9030908@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
 <1440022048-6285-2-git-send-email-al.stone@linaro.org>
 <55EDADF5.5060008@arm.com> <55F08F47.1070906@redhat.com>
 <55F1ADC4.7090005@arm.com>
In-Reply-To: <55F1ADC4.7090005@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>, Al Stone <al.stone@linaro.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "patches@linaro.org" <patches@linaro.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

On 09/10/2015 10:20 AM, Sudeep Holla wrote:
> 
> 
> On 09/09/15 20:57, Al Stone wrote:
>> On 09/07/2015 09:32 AM, Sudeep Holla wrote:
>>> Hi Al,
>>>
>>> On 19/08/15 23:07, Al Stone wrote:
>>>
>>> I finally got a chance to try this series on Juno. Well it exposed a firmware
>>> bug in MADT table :)
>>>
>>> [..]
>>>
>>>>                   acpi_tbl_entry_handler handler,
>>>> @@ -245,6 +484,8 @@ acpi_parse_entries(char *id, unsigned long table_size,
>>>>                  table_end) {
>>>>                   if (entry->type = entry_id
>>>>                       && (!max_entries || count < max_entries)) {
>>>> +                       if (bad_madt_entry(table_header, entry))
>>>> +                               return -EINVAL;
>>>
>>> Not sure if we can have the above check here unconditionally.
>>> Currently I can see there are 2 other users of acpi_parse_entries i.e.
>>> PCC and NUMA. So may be it can be made conditional or return success for
>>> non-MADT tables from bad_madt_entry ?
>>
>> So, I went back and double checked the other users and they're looking at
>> the return value for acpi_parse_entries properly; adding in the check above
>> unconditionally should not cause any behavior change.
> 
> I disagree. I populated PCCT table on Juno to get this error for
> PCCT(PCCT header gets interpreted as MADT header):
> "
> ACPI: undefined version for either FADT 5.1 or MADT 1
> Error parsing PCC subspaces from PCCT
> "
> And here the stacktrace:
> [<ffffffc000881e58>] bad_madt_entry+0x90/0x16c
> [<ffffffc000882030>] acpi_table_parse_entries+0xfc/0x180
> [<ffffffc000895af8>] pcc_init+0x70/0x148
> 
>> Further, despite the name, acpi_parse_entries is only used to examine MADT
>> subtables.  Granted, we should probably make the name clearer at some point
>> (too ambiguous as to which entries are parsed right now).  Nonetheless, current
>> usage seems to be in order.
>>
> 
> From the code inspection, I can see we have 3 users of acpi_parse_entries not
> just MADT but also PCC and NUMA/SRAT
> 
> Something like this solves this issue:
> -              if (bad_madt_entry(table_header, entry))
> +              if (!strncmp(id, ACPI_SIG_MADT, 4) &&
> +                      bad_madt_entry(table_header, entry)
> 
> 
> Or am I still missing something ?
> 
> Regards,
> Sudeep

Nope, I missed it.  Your fix above will solve the problem; I misunderstood
how acpi_parse_entries() was being used -- somehow I had it in my head that
only MADT was in use, and just not seeing that it's being used for several
other subtable traversals also.  Sorry about that, Sudeep.  My mistake.

I'll add this fix for a v4, but I'll wait for a few days to see if I get any
additional comments -- I haven't heard from any x86, ia64 or ACPI maintainers
yet.  OTOH, it's nice to know we've already found and fixed two sets of arm64
ACPI tables that are in error by using these patches, even with the flaws :).

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------
