From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jan 2006 17:59:35 +0000
Subject: Re: [RFC]: Standardizing the SAL calls in arch/ia64
Message-Id: <20060117175935.GA4944@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <43CBF385.60205@sgi.com>
In-Reply-To: <43CBF385.60205@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I agree with the principle, the current SAL code is an utter
> mess. However, rather than obfuscating the code with a bunch of
> macros, I'd prefer to simply stick a guideline at the top of the
> relevant files and then change the code to match that. In particular
> declaring variables within macros and macros that call 'return' aren't
> good for making the code easy to read.

If the SAL stubs are sufficently regular, then you *might* make
a macro (or small set of macros) to generate them:

#define MK_VOID_SAL_STUB(fname, salfn)			\
static inline s64					\
fname(void)						\
{							\
	struct ia64_sal_retval isrv;			\
	SAL_CALL(isrv, salfn, 0, 0, 0, 0, 0, 0, 0);	\
	return isrv.status;				\
}

MK_VOID_SAL_STUB(ia64_sal_cache_init, SAL_CACHE_INIT)


But I think that you'd end up with lots of generator macros that are
only used once each unless you are astonishingly clever[1] with cpp macros,
so you'd have been better off to just write them in C.

Macros to generate functions can also be irritating as tools like
cscope can't show you the definition ... but they are used elsewhere
in the Linux kernel.

Summary: take a quick look at whether macros might help, if not then
just clean up the C code.

-Tony

[1] which can have its own issues of code legibility.
