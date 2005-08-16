From: "Brown, Len" <len.brown@intel.com>
Date: Tue, 16 Aug 2005 16:08:04 +0000
Subject: refresh ia64 build configs?
Message-Id: <F7DC2337C7631D4386A2DF6E8FB22B300456A0CD@hdsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,
What's the word with arch/ia64/configs/*
They haven't been refreshed in a while.
Would it make sense to "make oldconfig" on them
and check in the refreshed configs?

As I recently broke the ia64 build in -mm I've
been poking around and some of the ACPI-related
dependencies don't look quite right (and my
auto-build script generates configs that don't build)

Are you planning to poke around in this area
or should I just send you some patches?
Anything I need to look out for?

thanks,
-Len

ps. my build script builds each of the arch/ia64/configs/*
defconfig, allnoconfig, and then it starts with defconfig
and individually pokes some ACPI-related items
(currently the 4 combinations of CONFIG_ACPI, CONFIG_SMP), 
runs make oldconfig and attempts to build the result.
I don't bother with allyesconfig or allmodconfig
since they appear hopeless, so it comes up with 11 configs.
3 configs currently fail -- the 3 non-simulator ones with 
CONFIG_ACPI=n.  It may be simpler to make nonsense configs
impossible rather than fixing the build for configs that
make no sense.

