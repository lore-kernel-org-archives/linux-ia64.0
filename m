From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 03 Jan 2008 22:07:49 +0000
Subject: RE: [RFC PATCH] clean up use of ia64 tool chain check scripts --resent
Message-Id: <1FE6DD409037234FAB833C420AA843EC388F61@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071220142053.GE4217@localhost.localdomain>
In-Reply-To: <20071220142053.GE4217@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

-GAS_STATUS	= $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)")
-CPPFLAGS += $(shell $(srctree)/arch/ia64/scripts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")

If we delete these calls from the Makefile, then should we also
delete the scripts themselves (and the test programs that they
use) from arch/ia64/scripts?

+CPPFLAGS += -DHAVE_WORKING_TEXT_ALIGN -DHAVE_MODEL_SMALL_ATTRIBUTE -DHAVE_SERIALIZE_DIRECTIVE

and if we are going to just unconditionally set these defines, perhaps
we should clean the #ifdef'd code out of the source tree so we can
remove this clutter from the Makefile too?

It all sounds good to me ... but I'll wait a few more days in case
somebody who knows better is still on their winter holiday break.
[This is 2.6.25 cleanup material anyway, so waiting is not an issue]

-Tony
