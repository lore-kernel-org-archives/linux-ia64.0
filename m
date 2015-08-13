From: Al Stone <al.stone@linaro.org>
Date: Thu, 13 Aug 2015 15:43:46 +0000
Subject: Re: [Linaro-acpi] [PATCH 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the mac
Message-Id: <55CCBB32.6000103@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438894770-31163-1-git-send-email-al.stone@linaro.org>
 <1438894770-31163-2-git-send-email-al.stone@linaro.org>
 <CAOZdJXVZomskfpvEjmDUiptW3SndJWvfKyzd9SwJp3dh7h3pig@mail.gmail.com>
In-Reply-To: <CAOZdJXVZomskfpvEjmDUiptW3SndJWvfKyzd9SwJp3dh7h3pig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>
Cc: linux-acpi@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

On 08/12/2015 04:35 PM, Timur Tabi wrote:
> On Thu, Aug 6, 2015 at 3:59 PM, Al Stone <al.stone@linaro.org> wrote:
>> +       while (ms->num_types != 0) {
>> +               if (ms->major_version = major &&
>> +                   ms->minor_version = minor &&
>> +                   ms->madt_version = madt->header.revision)
>> +                       break;
>> +               ms++;
>> +       }
>> +       if (!ms) {
> 
> Shouldn't this be
> 
>   if (!ms->num_types) {
> 
> instead?
> 

Argh.  Yes, it should.  It will always be false, otherwise.
Will fix for next version.  Thanks for catching that.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Linaro Enterprise Group
al.stone@linaro.org
-----------------------------------
