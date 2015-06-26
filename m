From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Fri, 26 Jun 2015 00:54:28 +0000
Subject: Re: [PATCH v2 03/28] ACPICA: Hardware: Enable 64-bit firmware waking vector for selected FACS.
Message-Id: <1649895.CEu8Ovje9D@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1434684719.git.lv.zheng@intel.com> <3959851.uJ0udqUY0b@vostro.rjw.lan> <1AE640813FDE7649BE1B193DEA596E8802733C14@SHSMSX101.ccr.corp.intel.com>
In-Reply-To: <1AE640813FDE7649BE1B193DEA596E8802733C14@SHSMSX101.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Zheng, Lv" <lv.zheng@intel.com>
Cc: "Wysocki, Rafael J" <rafael.j.wysocki@intel.com>, "Brown, Len" <len.brown@intel.com>, Lv Zheng <zetalog@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Moore, Robert" <robert.moore@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Thursday, June 25, 2015 12:29:02 AM Zheng, Lv wrote:
> Hi, Rafael
> 
> > From: Rafael J. Wysocki [mailto:rjw@rjwysocki.net]
> > Sent: Thursday, June 25, 2015 7:24 AM
> > To: Zheng, Lv

[cut]

> > 
> > In fact, I don't see why we need to redefine the symbols at all.
> > 
> > Couldn't acpi_set_firmware_waking_vector() be defined to take u32 and u64 so
> > we could just pass acpi_wakeup_address (as already defined) as the first argument
> > and 0 as the second argument to it?  The back-and-forth type casts from and
> > to acpi_physical_address don't look entirely clean to me.
> > 
> > Moreover, I don't really see a functional difference between the old and the
> > new code.
> > 
> > The old code does "set the 32-bit waking vector and clear the 64-bit waking
> > vector if present".  The new code does "set the 32-bit waking vector and
> > either clear the 64-bit one if present, or assign the second function argument
> > to it", but we always pass 0 as the second argument (which is *extremely*
> > obfuscated in your patch), so I really don't see the difference here.
> > 
> > Am I missing anything?
> 
> The story is:
> According to the test, if both 32-bit waking vector and 64-bit waking vector is
> set by the OSPM,

The current code in Linux never does that.

It never calls acpi_set_firmware_waking_vector64() and the acpi_set_firmware_waking_vector()
(before your patch) explicitly clears the 64-bit vector address.

> BIOSes only support 32-bit resume environment will jump to the 32-bit waking
> vector address and BIOSes support 64-bit resume environment will jump to
> 64-bit waking vector.

Which doesn't matter for Linux one whit.

> So they can be set by the OSPMs simultaneously to indicate that the OSPM can
> support both resume environments.  That's why ACPICA interface is changed.

It shouldn't.  It just forces host OSes to make pointless changes to their
non-ACPICA code.

As I said elsewhere, the old acpi_set_firmware_waking_vector() should still be
available to the OSes that don't care about the 64-bit waking vector and a *new*
interface should be added for those OSes that do care about it.  And *internally*
acpi_set_firmware_waking_vector() can be defined in terms of the new interface,
but there's no reason at all for a host OS to care about that.

So the $subject patch is entirely poitless.  It doesn't fix anything and it
doesn't even change the way the code works today in Linux.  It just adds
complexity and pointlessly redefines some stuff.

So I'm not going to apply it.

Thanks,
Rafael

