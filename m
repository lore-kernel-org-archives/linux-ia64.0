From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Sep 2009 18:11:03 +0000
Subject: RE: [PATCH] cleanup legacy console_print function
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E05DBC6E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C501F0FF17@exchange.ZeugmaSystems.local>
 <200909151127.10697.bjorn.helgaas@hp.com>
 <DDFD17CC94A9BD49A82147DDF7D545C501F100E4@exchange.ZeugmaSystems.local>
 <12c511ca0909151100ne3841b7l7af5bffb977d6d9b@mail.gmail.com>
 <DDFD17CC94A9BD49A82147DDF7D545C501F100EB@exchange.ZeugmaSystems.local>
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C501F100EB@exchange.ZeugmaSystems.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anirban Sinha <ASinha@zeugmasystems.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Randy Dunlap <randy.dunlap@oracle.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

> Will it resolve the function symbol though? I dunno.
>
> I can drop the head.h completely and add:
>
> #ifndef __ASSEMBLY__
> extern void console_print(const char *s);
> #endif
>
> to head.S if that is a better option.

head.S is in assembler (hence the ".S" suffix).  So adding
code wrapped inside #ifndef __ASSEMBLY__ to it would be a
no-op.

On ia64 (and I think most other assemblers) it is not
necessary to provide any kind of "extern" declaration
before using external symbols.

-Tony
