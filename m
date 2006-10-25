From: "Bjorn Helgaas" <bjorn.helgaas@hp.com>
Date: Wed, 25 Oct 2006 03:47:34 +0000
Subject: RE: ia64 acpi-cpufreq driver
Message-Id: <1134.24.9.204.52.1161748054.squirrel@mail.atl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <EB12A50964762B4D8111D55B764A8454C95BB5@scsmsx413.amr.corp.intel.com>
In-Reply-To: <EB12A50964762B4D8111D55B764A8454C95BB5@scsmsx413.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org

> Yes. As it is today, acpi-cpufreq contains FFH driver functionality
> in itself. It calls acpi and cpufreq arch-independent interfaces but
> implements FFH internally.
>
> By, FFH driver do you mean to handle FFH related functions only for
> P-states or something that can handle all FFH functions (like C-states,
> etc).
> I don't see any other kernel part/or driver will use this particular
> PAL_GET_PSTATE and PAL_SET_PSTATE intefaces. So, my feeling is we don't
> need a separate FFH driver.

The only reason I can think of to have a separate FFH driver
would be that we could potentially combine parts of the x86
acpi-cpufreq and the ia64 acpi-cpufreq.

I didn't look closely, but the x86 and ia64 acpi-cpufreq drivers
looked pretty different, even apart from the FFH stuff, so maybe
that wouldn't be feasible.

Bjorn

