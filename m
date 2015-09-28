From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 28 Sep 2015 21:13:01 +0000
Subject: Re: [PATCH v4 0/5] Provide better MADT subtable sanity checks
Message-Id: <CAJZ5v0hHfwpw2h26KJePVCcgd68QFK2mtiffwjpootVn4WtvsQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1442446005-19799-1-git-send-email-al.stone@linaro.org>
	<1883446.cx2ktyZcIz@vostro.rjw.lan>
	<5609A06A.5020802@redhat.com>
In-Reply-To: <5609A06A.5020802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Al Stone <ahs3@redhat.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Al Stone <al.stone@linaro.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, Lists linaro-kernel <linaro-kernel@lists.linaro.org>, "patches@linaro.org" <patches@linaro.org>

On Mon, Sep 28, 2015 at 10:17 PM, Al Stone <ahs3@redhat.com> wrote:
> On 09/25/2015 05:29 PM, Rafael J. Wysocki wrote:
>> On Wednesday, September 16, 2015 05:26:40 PM Al Stone wrote:

[cut]

>> In particular, I'm not sure if we really need to return
>> -EINVAL from acpi_parse_entries_array() when we find a bad MADT entry or it
>> will be sufficient to simply go to the next entry in that case?
>>
>> Thanks,
>> Rafael
>
> I see there being two options: (1) return -EINVAL and indicate that the tables
> are incorrect, or (2) print a warning (or something more aggressive?), go to
> the next entry, and hope for the best with the remainder of the MADT subtables.
> The former is consistent with past behavior, I think, and the latter seems to
> me a bit of a gamble.  So, my vote is for (1), the current method; what are you
> thinking these days?

I would be for preserving the past behavior.

I'm a bit concerned that the new checks may trigger on systems where
the old ones didn't, but that is a separete problem.

Thanks,
Rafael
