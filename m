From: "Anirban Sinha" <ASinha@zeugmasystems.com>
Date: Tue, 15 Sep 2009 18:05:43 +0000
Subject: RE: [PATCH] cleanup legacy console_print function
Message-Id: <DDFD17CC94A9BD49A82147DDF7D545C501F100EB@exchange.ZeugmaSystems.local>
List-Id: <linux-ia64.vger.kernel.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C501F0FF17@exchange.ZeugmaSystems.local> <200909151127.10697.bjorn.helgaas@hp.com> <DDFD17CC94A9BD49A82147DDF7D545C501F100E4@exchange.ZeugmaSystems.local> <12c511ca0909151100ne3841b7l7af5bffb977d6d9b@mail.gmail.com>
In-Reply-To: <12c511ca0909151100ne3841b7l7af5bffb977d6d9b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, linux-ia64@vger.kernel.org


>Umm.  Your new file "head.h" is only included by head.S ... perhaps it
>would be
>better to delete head.h entirely and drop the #include from head.S?
>

Will it resolve the function symbol though? I dunno.

I can drop the head.h completely and add:

#ifndef __ASSEMBLY__
 extern void console_print(const char *s);
#endif

to head.S if that is a better option.

  Ani

