From: Thomas Renninger <trenn@suse.de>
Date: Thu, 16 Aug 2007 17:03:37 +0000
Subject: RE: scripts/mod/file2alias.c cross compile problem
Message-Id: <1187283817.8780.837.camel@queen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0211AFF0@scsmsx411.amr.corp.intel.com>
	 <1186092501.6131.154.camel@localhost.localdomain>
	 <1187274435.8780.780.camel@queen.suse.de>
	 <617E1C2C70743745A92448908E030B2A022DBC43@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A022DBC43@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Adrian Bunk <bunk@stusta.de>, Sam Ravnborg <sam@ravnborg.org>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Thu, 2007-08-16 at 09:26 -0700, Luck, Tony wrote:
> > -#define ACPI_ID_LEN	9
> > +#define ACPI_ID_LEN	16 /* only 9 bytes needed here, 16 bytes are used */
> 
> What will happen if someone uses more than 9 bytes?  With the old
> limit there would be a compile time error it someone initialized
> with:
> 
> 	{"PNP0C0ABCDEFGH", 0},
> 
> But if we change ACPI_ID_LEN the error will move to run-time.

That should not harm.
From spec point of view only 8 bytes are needed. Here 9 bytes are used
as then string functions can be used. The whole rest of the kernel does
not use ACPI_ID_LEN.
If someone defines such an id, his driver won't ever get loaded and he
gets bug reports very soon anyway.

Hmm, I wonder whether this even may come in handy later:
Some BIOSes have some spec violating strange hids like:
"*PNP0C0A"
or
"_PNP0C0A"
While I thought the "_" or "*" should be cut away by ACPI parser, it
might be a hint to the OS to do something special. AFAIK only very
specific devices (WMI and some graphics?) have such strange hids
defined, those drivers could explicitly match for the spec violating
string then.

   Thomas

