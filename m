From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 04 Mar 2003 19:57:53 +0000
Subject: Re: [Linux-ia64] _raw_write_trylock() missing
Message-Id: <marc-linux-ia64-105590709805960@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805809@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805809@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 4 Feb 2003 15:18:22 +0100 (NFT), Joel GUILLET <Joel.Guillet@bull.net> said:

  Joel> Here is an implementation of "_raw_write_trylock_ " needed for
  Joel> preemption support with SMP.  I tested it on a 2.5.59 kernel
  Joel> with 2 Itaniums. It seems to work.

I included your change, after dropping the (unnecessary) clobber of r2
and and the label (final result is below).  Let me know if you have
any issue with this.

Thanks,

	--david

#define _raw_spin_trylock(x)								\
({											\
	register long result;								\
											\
	__asm__ __volatile__ (								\
		"mov ar.ccv=r0\n"							\
		";;\n"									\
		"cmpxchg4.acq %0=[%2],%1,ar.ccv\n"					\
		: "=r"(result) : "r"(1), "r"(&(x)->lock) : "ar.ccv", "memory");		\
	(result = 0);									\
})

