From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Mar 2002 03:13:44 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.18-ia64-020226 generalize exception recovery
Message-Id: <marc-linux-ia64-105590701905271@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 13:43:19 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> +#ifdef GAS_HAS_LOCAL_TAGS
  Keith> +#define HANDLE_EXCEPTION_1(regs) search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
  Keith> +#else
  Keith> +#define HANDLE_EXCEPTION_1(regs) search_exception_table(regs->cr_iip);
  Keith> +#endif
  Keith> +#define HANDLE_EXCEPTION(regs)			\
  Keith> +{						\
  Keith> +	struct exception_fixup fix;		\
  Keith> +	fix = HANDLE_EXCEPTION_1(regs);		\
  Keith> +	if (fix.cont) {				\
  Keith> +		handle_exception(regs, fix);	\
  Keith> +		return;				\
  Keith> +	}					\
  Keith> +}

I'm OK with the first macro (rename it to SEARCH_EXCEPTION_TABLE,
though), but the HANDLE_EXCEPTION() macro is ugly: it looks like a
statement, when in fact it's a conditional return.

	--david

