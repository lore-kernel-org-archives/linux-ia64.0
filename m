From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Mon, 25 Jul 2016 15:30:14 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160726003014.8e0424d2991ec71ad5e0ac5f@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	<1469222687-1600-8-git-send-email-mcgrof@kernel.org>
In-Reply-To: <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-devel@li

On Fri, 22 Jul 2016 14:24:41 -0700
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> +/**
> + * LINKTABLE_RUN_ALL - iterate and run through all entries on a linker table
> + *
> + * @tbl: linker table
> + * @func: structure name for the function name we want to call.
> + * @args...: arguments to pass to func
> + *
> + * Example usage:
> + *
> + *   LINKTABLE_RUN_ALL(frobnicator_fns, some_run,);
> + */
> +#define LINKTABLE_RUN_ALL(tbl, func, args...)				\
> +do {									\
> +	size_t i;							\
> +	for (i = 0; i < LINUX_SECTION_SIZE(tbl); i++)			\
> +		(tbl[i]).func (args);					\
> +} while (0);
> +
> +/**
> + * LINKTABLE_RUN_ERR - run each linker table entry func and return error if any
> + *
> + * @tbl: linker table
> + * @func: structure name for the function name we want to call.
> + * @args...: arguments to pass to func
> + *
> + * Example usage:
> + *
> + *   unsigned int err = LINKTABLE_RUN_ERR(frobnicator_fns, some_run,);
> + */
> +#define LINKTABLE_RUN_ERR(tbl, func, args...)				\
> +({									\
> +	size_t i;							\
> +	int err = 0;							\
> +	for (i = 0; !err && i < LINUX_SECTION_SIZE(tbl); i++)		\
> +		err = (tbl[i]).func (args);				\
> +		err; \
> +})

These iteration APIs are a bit dangerous, at least for these APIs we'd better change
name like as FUNCTABLE_RUN etc. because LINKTABLE can contain not only function address
but also some data (or address of data).

Thank  you,


-- 
Masami Hiramatsu <mhiramat@kernel.org>
