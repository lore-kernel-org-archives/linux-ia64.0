From: Al Stone <ahs3@redhat.com>
Date: Thu, 10 Sep 2015 14:13:36 +0000
Subject: Re: [Linaro-acpi] [PATCH v3 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the 
Message-Id: <55F19010.9060603@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1441832991-28200-1-git-send-email-al.stone@linaro.org>
 <1441832991-28200-2-git-send-email-al.stone@linaro.org>
 <20150910121413.GA11267@xora-haswell.xora.org.uk>
In-Reply-To: <20150910121413.GA11267@xora-haswell.xora.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Graeme Gregory <graeme.gregory@linaro.org>, Al Stone <al.stone@linaro.org>
Cc: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Len Brown <lenb@kernel.org>

On 09/10/2015 06:14 AM, Graeme Gregory wrote:
> On Wed, Sep 09, 2015 at 03:09:47PM -0600, Al Stone wrote:
>> The existing BAD_MADT_ENTRY macro only checks that the size of the data
>> structure for an MADT subtable matches the length entry in the subtable.
>> This is, unfortunately, not reliable.  Nor, as it turns out, does it have
>> anything to do with what the length should be in any particular table.
>>

[snip...]
  			if (handler(entry, table_end))
>>  				return -EINVAL;
>>  
>> @@ -349,7 +592,7 @@ int __init acpi_table_parse(char *id, acpi_tbl_table_handler handler)
>>  		return -ENODEV;
>>  }
>>  
>> -/* 
>> +/*
>>   * The BIOS is supposed to supply a single APIC/MADT,
>>   * but some report two.  Provide a knob to use either.
>>   * (don't you wish instance 0 and 1 were not the same?)
> 
> Unrelated whitespace change snuck in here.
> 
> Graeme

Bah.  Nice catch; not sure how that got in there, but duly noted.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------
