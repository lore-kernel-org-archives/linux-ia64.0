From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 05 Apr 2002 21:27:36 +0000
Subject: Re: [Linux-ia64] SIGILL errors in strncpu (NAT consumption)
Message-Id: <marc-linux-ia64-105590701905395@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905358@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905358@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just to avoid confusing others, I'd like to clarify this point:

  >> (1) I don't think it's save to do:
  >>
  >> chk.s r[MEMLAT], .recovery3
  >> mov value = r[MEMLAT]
  >>
  >> in the same cycle.

This was a brain fart.  It is of course legal to do this as there is
no dependency violation (both instructions only read r[MEMLAT]) and
hence the effect of the instructions is as if they had been executed
sequentially.  Thanks to Jim Hull for setting me straight.

The rest of the patch should still apply.

	--david

