From: Tony Luck <tony.luck@intel.com>
Date: Tue, 15 Sep 2009 18:00:29 +0000
Subject: Re: [PATCH] cleanup legacy console_print function
Message-Id: <12c511ca0909151100ne3841b7l7af5bffb977d6d9b@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C501F0FF17@exchange.ZeugmaSystems.local>
	 <200909151127.10697.bjorn.helgaas@hp.com>
	 <DDFD17CC94A9BD49A82147DDF7D545C501F100E4@exchange.ZeugmaSystems.local>
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C501F100E4@exchange.ZeugmaSystems.local>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Anirban Sinha <ASinha@zeugmasystems.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Randy Dunlap <randy.dunlap@oracle.com>, linux-ia64@vger.kernel.org

> --- a/arch/ia64/kernel/head.h
> +++ b/arch/ia64/kernel/head.h
> @@ -1 +1,3 @@
> +#ifndef __ASSEMBLY__
> =A0extern void console_print(const char *s);
> +#endif

Umm.  Your new file "head.h" is only included by head.S ... perhaps it woul=
d be
better to delete head.h entirely and drop the #include from head.S?

-Tony
