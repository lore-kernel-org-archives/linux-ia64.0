From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 16 Aug 2005 16:40:56 +0000
Subject: RE: refresh ia64 build configs?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04264836@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <F7DC2337C7631D4386A2DF6E8FB22B300456A0CD@hdsmsx401.amr.corp.intel.com>
In-Reply-To: <F7DC2337C7631D4386A2DF6E8FB22B300456A0CD@hdsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>What's the word with arch/ia64/configs/*
>They haven't been refreshed in a while.
>Would it make sense to "make oldconfig" on them
>and check in the refreshed configs?

I periodically do this for tiger_defconfig and zx1_defconfig
(the ones that match the machines that I physically test on).
SGI have historically updated sn2_defconfig, and defconfig.
Bigsur and hpsim are mostly left to fend for themselves.
[How many bigsurs are still running?]

>As I recently broke the ia64 build in -mm I've
>been poking around and some of the ACPI-related
>dependencies don't look quite right (and my
>auto-build script generates configs that don't build)
>
>Are you planning to poke around in this area
>or should I just send you some patches?
>Anything I need to look out for?

No plans beyond an occasional "make oldconfig".  Having someone
apply some intelligence to the configs would definitely be
a good thing.  Patches are always welcome.

>ps. my build script builds each of the arch/ia64/configs/*
>defconfig, allnoconfig, and then it starts with defconfig
>and individually pokes some ACPI-related items
>(currently the 4 combinations of CONFIG_ACPI, CONFIG_SMP), 
>runs make oldconfig and attempts to build the result.
>I don't bother with allyesconfig or allmodconfig
>since they appear hopeless, so it comes up with 11 configs.

I feel like such a slacker ... I only build 9 configs:
  {defconfig, tiger, zx1} * {UP, SMP }
  sn2
  bigsur
  hpsim

>3 configs currently fail -- the 3 non-simulator ones with 
>CONFIG_ACPI=n.  It may be simpler to make nonsense configs
>impossible rather than fixing the build for configs that
>make no sense.

Agreed.  It would be better to not allow impossible configs.

-Tony
