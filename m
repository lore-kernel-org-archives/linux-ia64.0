From: Al Stone <ahs3@redhat.com>
Date: Wed, 26 Aug 2015 20:30:25 +0000
Subject: Re: [PATCH v2 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <55DE21E1.6070700@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
 <1440022048-6285-2-git-send-email-al.stone@linaro.org>
 <CAOZdJXXCnb7ChYqh-QYptTQBmfESDPaauThHyu8Dav6Qs_+4Bw@mail.gmail.com>
In-Reply-To: <CAOZdJXXCnb7ChYqh-QYptTQBmfESDPaauThHyu8Dav6Qs_+4Bw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, Al Stone <al.stone@linaro.org>
Cc: linux-acpi@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

On 08/26/2015 09:38 AM, Timur Tabi wrote:
> On Wed, Aug 19, 2015 at 5:07 PM, Al Stone <al.stone@linaro.org> wrote:
>> +                               pr_err("Variable length MADT subtable %d is wrong size: %d\n",
>> +                                      entry->type, entry->length);
>> +                               return 1;
>> +                       }
>> +               }
>> +       } else {
>> +               if (entry->length != len) {
>> +                       pr_err("MADT subtable %d is wrong size: %d\n",
>> +                              len, entry->type);
> 
> Can we make these a little more descriptive?
> 
> pr_err("Variable length MADT subtable type %d is wrong size: %d,
> should be %d\n",
>       entry->type, entry->length, len);
> 
> pr_err("MADT subtable type %d is wrong size: %d, should be %d\n",
>       entry->type, entry->length, len);
> 

Sure.  It's always a fine line between verbose and not enough info.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------
