From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 05 Mar 2015 12:56:24 +0000
Subject: Re: [PATCH v3 8/9] ACPI: arm64: use an arch-specific ACPI _OSI method and ACPI blacklist
Message-Id: <CAJZ5v0g_1T_5dMzDrPNObQ3MPboMz9jVaT0fioRq5mDusc2dFQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1424824585-6405-1-git-send-email-al.stone@linaro.org>
	<20150302172939.GC7919@arm.com>
	<54F4B345.6020001@linaro.org>
	<2149383.4T7uuqhSe1@vostro.rjw.lan>
	<20150305101705.GB5287@arm.com>
In-Reply-To: <20150305101705.GB5287@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Al Stone <al.stone@linaro.org>, "lenb@kernel.org" <lenb@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "robert.moore@intel.com" <robert.moore@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "fenghua.yu@intel.com" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devel@acpica.org" <devel@acpica.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linaro-acpi@lists.linaro.org" <linaro-acpi@lists.linaro.org>, "linaro-kernel@lists.linaro.org" <linaro-kernel@lists.linaro.org>, "patches@linaro.org" <patches@linaro.org>

On Thu, Mar 5, 2015 at 11:17 AM, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Mar 04, 2015 at 11:14:50PM +0000, Rafael J. Wysocki wrote:
>> On Monday, March 02, 2015 12:00:21 PM Al Stone wrote:
>> > On 03/02/2015 10:29 AM, Will Deacon wrote:
>> > > On Wed, Feb 25, 2015 at 12:36:24AM +0000, al.stone@linaro.org wrote:
>> > >> diff --git a/arch/arm64/kernel/acpi-blacklist.c b/arch/arm64/kernel/acpi-blacklist.c
>> > >> new file mode 100644
>> > >> index 0000000..1be6a56
>> > >> --- /dev/null
>> > >> +++ b/arch/arm64/kernel/acpi-blacklist.c
>> > >> @@ -0,0 +1,20 @@
>> > >> +/*
>> > >> + *  ARM64 Specific ACPI Blacklist Support
>> > >> + *
>> > >> + *  Copyright (C) 2015, Linaro Ltd.
>> > >> + *      Author: Al Stone <al.stone@linaro.org>
>> > >> + *
>> > >> + *  This program is free software; you can redistribute it and/or modify
>> > >> + *  it under the terms of the GNU General Public License version 2 as
>> > >> + *  published by the Free Software Foundation.
>> > >> + */
>> > >> +
>> > >> +#define pr_fmt(fmt) "ACPI: " fmt
>> > >> +
>> > >> +#include <linux/acpi.h>
>> > >> +
>> > >> +/* The arm64 ACPI blacklist is currently empty.  */
>> > >> +int __init acpi_blacklisted(void)
>> > >> +{
>> > >> +        return 0;
>> > >> +}
>> > >> diff --git a/arch/arm64/kernel/acpi-osi.c b/arch/arm64/kernel/acpi-osi.c
>> > >> new file mode 100644
>> > >> index 0000000..bb351f4
>> > >> --- /dev/null
>> > >> +++ b/arch/arm64/kernel/acpi-osi.c
>> > >> @@ -0,0 +1,25 @@
>> > >> +/*
>> > >> + *  ARM64 Specific ACPI _OSI Support
>> > >> + *
>> > >> + *  Copyright (C) 2015, Linaro Ltd.
>> > >> + *      Author: Al Stone <al.stone@linaro.org>
>> > >> + *
>> > >> + *  This program is free software; you can redistribute it and/or modify
>> > >> + *  it under the terms of the GNU General Public License version 2 as
>> > >> + *  published by the Free Software Foundation.
>> > >> + */
>> > >> +
>> > >> +#define pr_fmt(fmt) "ACPI: " fmt
>> > >> +
>> > >> +#include <linux/acpi.h>
>> > >> +
>> > >> +/*
>> > >> + * Consensus is to deprecate _OSI for all new ACPI-supported architectures.
>> > >> + * So, for arm64, reduce _OSI to a warning message, and tell the firmware
>> > >> + * nothing of value.
>> > >> + */
>> > >> +u32 acpi_osi_handler(acpi_string interface, u32 supported)
>> > >> +{
>> > >> +        pr_warn("_OSI was called, but is deprecated for this architecture.\n");
>> > >> +        return false;
>> > >> +}
>> > >
>> > > This kinda feels backwards to me. If _OSI is going away, then the default
>> > > should be "the architecture doesn't need to do anything", rather than have
>> > > new architectures defining a bunch of empty, useless stub code.
>> > >
>> > > Anyway we could make this the default in core code and have architectures
>> > > that *do* want _OSI override that behaviour, instead of the other way around?
>> > >
>> > We could do that; I personally don't have a strong preference either way,
>> > so I'm inclined to make it whatever structure Rafael thinks is proper since
>> > it affects ACPI code most.  That being said, the current patch structure
>> > made sense to me since it wasn't distorting existing code much -- and given
>> > the pure number of x86/ia64 machines vs ARM machines using ACPI, that seemed
>> > the more cautious approach.
>> >
>> > @Rafael: do you have an opinion/preference?
>>
>> My preference is to avoid changes in the existing code at least for the time
>> being.  Especially if the changes in question are going to affect ia64, unless
>> you have an Itanium machine where you can readily test those, that is. :-)
>
> Well, this code doesn't even need to compiled for ia64 if we have those
> architectures that want to use _OSI select a Kconfig symbol for it, so I
> don't think the testing argument is really that valid. I appreciate that you
> want to avoid changing the existing code, but I also don't want to add this
> sort of stuff to the architecture code, when it really has nothing to do
> with the architecture.

OK, so consider this.

_OSI may be deprecated in the spec for *new* implementations.

However, there still are many systems out there that use _OSI and
we'll need to support
them going forward.  So while the spec people may think that they have
deprecated
_OSI, the reality is that in the kernel it is not going to be
deprecated as long as there
are systems using it that we need to support.

So the whole "_OSI is going away" argument is simply bogus and useless.

That aside, yes, we can use a Kconfig symbol to select from x86 and ia64
and compile the generic code conditional on that.  That would be fine by me.

Rafael
