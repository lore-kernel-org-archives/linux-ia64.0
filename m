From: Pete Wyckoff <pw@osc.edu>
Date: Wed, 11 Oct 2000 23:10:38 +0000
Subject: Re: [Linux-ia64] avoiding float underflow software assist
Message-Id: <marc-linux-ia64-105590678205564@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205556@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205556@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

jes@linuxcare.com said:
> >>>>> "Pete" = Pete Wyckoff <pw@osc.edu> writes:
> Pete> Gcc and glibc seem only to care about st0.  The "minimal" fix,
> Pete> which relies on glibc and exercises its fe*env functions, is:
> 
> We discussed this recently and David strongly opted for glibc setting
> s2/s3 the same way we set s0. I need to look closer at this in order
> to figure out how to deal with the get-then-set case but I think it's
> coming.

There's this method of masking just the control bits of sf0 into sf* if
you'd rather not provide direct library access to the fpsr.  E.g., to
set ftz in s0:

    asm volatile("fsetc.s0 0x7f, 0x01");

Or dup s0 into s2:

    asm volatile("fsetc.s2 0x7f, 0x00");

Not sure if/why intel gave us this instruction.  Perhaps switching speed
is important to some apps.

		-- Pete

