From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 10 Oct 2001 22:17:01 +0000
Subject: Re: [Linux-ia64] use of setcontext()/getcontext()
Message-Id: <marc-linux-ia64-105590698805322@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805251@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805251@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 9 Oct 2001 08:01:16 +0200 (CEST), stefan <stefan@lkcc.org> said:

  Stefan> One more question about this: The `ucontext_t' structure
  Stefan> seemed to changed a bit over the weeks. Since when is it
  Stefan> known to have the sc_ar_bsp member (glibc version) ?

I thought that member was there pretty much "forever".  However, I did
add sc_rbs_base and sc_loadrs recently.  This is really for
sigcontext, but since ucontext_t is effectively an alias, it would be
affected, too.

  Stefan> Also I would like to know if

  Stefan> extern unsigned long
  Stefan> __libc_ia64_register_backing_store_base; or extern void *
  Stefan> __libc_ia64_register_backing_store_base;

  Stefan> is meant to be correct.

Either one should work.

	--david

