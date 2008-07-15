From: Alex Chiang <achiang@hp.com>
Date: Tue, 15 Jul 2008 23:54:01 +0000
Subject: Re: [PATCH 00/14] Introduce cpu_enabled_map and friends
Message-Id: <20080715235401.GG10919@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080715023344.2528.1836.stgit@blender.achiang> <57C9024A16AD2D4C97DC78E552063EA306594DA5@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA306594DA5@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, linux-ia64@vger.kernel.org

I didn't include linux-ia64 originally. Sorry about that.

Here is the 00/14 cover email describing the patch series:

	http://lkml.org/lkml/2008/7/14/468

Here is the 12/14 ia64 specific bit:

	http://lkml.org/lkml/2008/7/14/478

Here is the 14/14 patch that Tony is referring to:

	http://lkml.org/lkml/2008/7/14/482

* Luck, Tony <tony.luck@intel.com>:
> > Patch 14 is the money patch. It demonstrates why we might
> > want to go through all these gyrations. Now that ia64 presents
> > *all* physically present CPUs in sysfs, even if they have been
> > disabled by firmware, we give userspace a way to poke at those
> > CPUs.
> 
> There's only the one bit for "disabled by firmware" ... no extra
> space for any extra information.  How would userspace know that
> it was safe to poke at a disabled cpu?  Perhaps firmware disabled
> it for some very good reason, and poking at it could cause system
> instability.

My thought here was that it would be a vendor-specific thing. In
patch 14/14 I created:

	/sys/devices/system/cpu/cpuN/deconfigure

(although /sys/device/system/cpu/cpuN/enabled would probably be
better)

I set up 'deconfigure' to have different implementations based on
a DMI, so it is very much an opt-in (especially since it's a
Kconfig option).

It would be the responsibility of the vendor to provide something
safe to poke at. In the sample implementation I gave, nothing
happens to the system until the *next* reboot, so it shouldn't
cause the current boot any distress.

A different implementation of deconfigure/enabled could return
an error to userspace if an operation was unsafe.

/ac

