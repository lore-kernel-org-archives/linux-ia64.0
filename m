From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 Mar 2003 22:06:39 +0000
Subject: Re: [Linux-ia64] Re: [patch] 2.4.20 unwind.c to handle multiple struct pt_regs
Message-Id: <marc-linux-ia64-105590709805963@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805882@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805882@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 20 Feb 2003 12:29:20 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> Two patches follow.  The first updates include/asm-ia64/unwind.h,
  Keith> arch/ia64/kernel/unwind_i.h, arch/ia64/kernel/unwind.c to handle
  Keith> multiple pt_regs on stack.  The second only updates unwind.c, it goes
  Keith> over the first patch to clean up the debug code, using UNW_DPRINT().

I applied most of these two patches now.  I omitted the portions where
you turned error messages into debug statements.  Also, I'm going to
change dump_info_pt() into something more reasonable.

	--david

