From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 09 Dec 2002 21:21:07 +0000
Subject: Re: [Linux-ia64] Unwind can load wrong data from pt_regs
Message-Id: <marc-linux-ia64-105590709805525@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805516@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805516@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 09 Dec 2002 19:35:03 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> This implicitly assumes that when a fr or br register is
  Keith> required from pt_regs, info->sp is pointing to pt_regs.  But
  Keith> info->sp is modified as the code unwinds through each
  Keith> function.  The above code only gives correct results for
  Keith> register lookups from the failing function.  Unwinding and
  Keith> accessing a fr or br register from earlier functions loads
  Keith> incorrect values for those registers.

Yes, this is something that has been fixed already in the user-level
libunwind.  It's not hard to fix, just someone needs to get around to
do it.  I don't think it's a critical issue, since it only happens for
nested traps.  I assume you saw this with kdb?

	--david

