From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 03 Aug 2005 18:15:58 +0000
Subject: xen patch
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F040F7016@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dan,

Can you send me <asm/xen/privop.h> so I can see where all
this indirection is leading to?

Like David Mosberger I'm a bit sceptical about the need to replace
constructs like:

	ia64_getreg(_IA64_REG_AR_EFLAG)

with
	ia64_get_eflag()

but I can't see the whole picture at the moment.

-Tony
