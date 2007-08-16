From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 16 Aug 2007 16:26:42 +0000
Subject: RE: scripts/mod/file2alias.c cross compile problem
Message-Id: <617E1C2C70743745A92448908E030B2A022DBC43@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0211AFF0@scsmsx411.amr.corp.intel.com> <1186092501.6131.154.camel@localhost.localdomain> <1187274435.8780.780.camel@queen.suse.de>
In-Reply-To: <1187274435.8780.780.camel@queen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: trenn@suse.de, Rusty Russell <rusty@rustcorp.com.au>
Cc: Adrian Bunk <bunk@stusta.de>, Sam Ravnborg <sam@ravnborg.org>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> -#define ACPI_ID_LEN	9
> +#define ACPI_ID_LEN	16 /* only 9 bytes needed here, 16 bytes are used */

What will happen if someone uses more than 9 bytes?  With the old
limit there would be a compile time error it someone initialized
with:

	{"PNP0C0ABCDEFGH", 0},

But if we change ACPI_ID_LEN the error will move to run-time.

-Tony
