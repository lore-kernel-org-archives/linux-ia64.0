From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 20 Jun 2003 23:08:28 +0000
Subject: Re: atomic.h vs spinlock.h
Message-Id: <marc-linux-ia64-105615055203234@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105615005202860@msgid-missing>
In-Reply-To: <marc-linux-ia64-105615005202860@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 20 Jun 2003 16:00:45 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> 1) what is the difference between the macros defined in
  Umut> asm/atomic.h and asm/spinlock.h. (usage and purpose wise)?

The first provides atomic operations, such as increment and decrement;
the second provides spinlocks.  I'm afraid I'm just stating the
obvious here.

In case you have a copy of my book (ia64 linux kernel), atomic ops and
spinlocks are described in sections 3.3.2 and 3.3.5, respectively.
(Of course, I wouldn't recommend to get the book _just_ because of
this.)

  Umut> 2) If I need to use asm/atomic.h, which macro can I use to
  Umut> test-and-set?

cmpxchg() is the closest thing to test-and-set.  Not all platforms support it.
Platforms that do support it (such as ia64), define macro __HAVE_ARCH_CMPXCHG.

	--david
