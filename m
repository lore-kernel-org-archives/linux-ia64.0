From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 15 Oct 2001 18:16:20 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805344@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 11 Oct 2001 13:26:05 +0200 (CEST), stefan <stefan@lkcc.org> said:

  Stefan> On Wed, 10 Oct 2001, David Mosberger wrote: Also I would
  Stefan> like to know if
  >>
  Stefan> extern unsigned long
  Stefan> __libc_ia64_register_backing_store_base; or extern void *
  Stefan> __libc_ia64_register_backing_store_base;
  >>
  Stefan> is meant to be correct.
  >>  Either one should work.

  Stefan> I know that :-) But how is it initially declared ? I just
  Stefan> need to decide which to chose.

Well, it's defined in an assembly file, so there is no initial
declaration.  I'd recommend to declare it as "unsigned long *".  That
way, it would be compatible with the rse.h helper functions (not that
you'd need them... ;-).

	--david

