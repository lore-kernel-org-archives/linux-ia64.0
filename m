From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 Jan 2007 23:19:06 +0000
Subject: RE: IA64 ACPI build issues
Message-Id: <617E1C2C70743745A92448908E030B2A0109E59A@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200701232348.30214.lenb@kernel.org>
In-Reply-To: <200701232348.30214.lenb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Len Brown <lenb@kernel.org>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

> Some of the IA64 code assumes that ACPI is optional,
> and some assumes that it is not.

The situation now is that the simulator doesn't want ACPI, and everything
else needs it (even "allnoconfig" ends up with CONFIG_ACPI=y!).  So the
solution that you suggest near the end of your mail of making CONFIG_ACPI=y
required, and somehow cleverly deal with the fallout in sim_defconfig would
be the neatest (if we were clever enough to do this without an explosion
of #ifdefs all over the place ... I don't know how complex this would get.
A brief forray into Kconfig-file-land showed multiple levels of defenses
preventing ACPI ever getting near CONFIG_HP_SIM ... I ripped out the first
two layers and still didn't get asked whether I wanted ACPI (and couldn't
immediately see where the third layer of defenses was located).

> But right behind this build issue is the IA64 PCI code assuming ACPI as well...

Which is probably in the same category ... PCI gets excluded by HP_SIM, but
for everyone else (again including allnoconfig) CONFIG_PCI=y

> How do you want to proceed?
> I assume that
> 1. configs that are theoretically possible, but  would run on nothing, should be discouraged
>    as they become maintainer make-work that benefits nobody.
Discouraged ... sure.  So if there is an easy tweak to a Kconfig file
to stop someone from configuring something that won't work, that's
definitely a good thing.  How much effort to expend on more complex
cases to stop people shooting themselves in the foot is a much greyer
area.  Right now we let people configure in all sorts of devices that
have zero probabability of ever being installed in an ia64 box.

> 2. littering the code with #ifdef  CONFIG_ACPI should be minimized.
Yup ... #fidef's are bad, #ifdef CONFIG_* doubly so (the Makefile syntax
of "objects-$(CONFIG_FOO) += foo.o" is pure magic).

So no definitive answers ... just a pointer to what I think is
the right direction.

-Tony
