From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Thu, 13 Aug 2015 09:30:36 +0000
Subject: Re: [Linaro-acpi] [PATCH 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the mac
Message-Id: <55CC63BC.4080902@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438894770-31163-1-git-send-email-al.stone@linaro.org>	<1438894770-31163-2-git-send-email-al.stone@linaro.org> <CAOZdJXVZomskfpvEjmDUiptW3SndJWvfKyzd9SwJp3dh7h3pig@mail.gmail.com>
In-Reply-To: <CAOZdJXVZomskfpvEjmDUiptW3SndJWvfKyzd9SwJp3dh7h3pig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Timur Tabi <timur@codeaurora.org>, Al Stone <al.stone@linaro.org>
Cc: linux-acpi@vger.kernel.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, lkml <linux-kernel@vger.kernel.org>, Len Brown <lenb@kernel.org>

On 08/13/2015 06:35 AM, Timur Tabi wrote:
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
>    if (!ms->num_types) {
>
> instead?

I think so, but seems nothing to do with the FADT version,
Al may explain more about it :)

Thanks
Hanjun
