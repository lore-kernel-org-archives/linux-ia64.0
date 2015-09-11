From: Sudeep Holla <sudeep.holla@arm.com>
Date: Fri, 11 Sep 2015 08:49:43 +0000
Subject: Re: [PATCH v2 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <55F295A7.20406@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
 <1440022048-6285-2-git-send-email-al.stone@linaro.org>
 <55EDADF5.5060008@arm.com> <55F08F47.1070906@redhat.com>
 <55F1ADC4.7090005@arm.com> <55F1EB81.9030908@redhat.com>
In-Reply-To: <55F1EB81.9030908@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <ahs3@redhat.com>, Al Stone <al.stone@linaro.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
Cc: Sudeep Holla <sudeep.holla@arm.com>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "patches@linaro.org" <patches@linaro.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>



On 10/09/15 21:43, Al Stone wrote:
> On 09/10/2015 10:20 AM, Sudeep Holla wrote:
>>

[...]

>>
>>  From the code inspection, I can see we have 3 users of acpi_parse_entries not
>> just MADT but also PCC and NUMA/SRAT
>>
>> Something like this solves this issue:
>> -              if (bad_madt_entry(table_header, entry))
>> +              if (!strncmp(id, ACPI_SIG_MADT, 4) &&
>> +                      bad_madt_entry(table_header, entry)
>>
>>
>> Or am I still missing something ?
>
> Nope, I missed it.  Your fix above will solve the problem; I misunderstood
> how acpi_parse_entries() was being used -- somehow I had it in my head that
> only MADT was in use, and just not seeing that it's being used for several
> other subtable traversals also.  Sorry about that, Sudeep.  My mistake.
>

No worries.

> I'll add this fix for a v4, but I'll wait for a few days to see if I get any
> additional comments -- I haven't heard from any x86, ia64 or ACPI maintainers

Makes sense.

> yet.  OTOH, it's nice to know we've already found and fixed two sets of arm64
> ACPI tables that are in error by using these patches, even with the flaws :).
>

Very much true indeed :)

Regards,
Sudeep
