From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 22 Dec 2016 13:58:18 +0000
Subject: Re: [PATCH v5 04/14] tables.h: add linker table support
Message-Id: <1482415098.9552.123.camel@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
         <20161222023811.21246-1-mcgrof@kernel.org>
         <20161222023811.21246-5-mcgrof@kernel.org>
In-Reply-To: <20161222023811.21246-5-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk
Cc: x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, paul.gortmaker@windriver.com, xen-devel@lists.xensource.com, ak@linux.intel.com, pali.rohar@gmail.com, dvhart@infradead.org, platform-driver-x86@vger.kernel.org, mmarek@suse.com, linux@rasmusvillemoes.dk, jkosina@suse.cz, korea.drzix@gmail.com, linux-kbuild@vger.kernel.org, tony.luck@intel.com, akpm@lin

On Wed, 2016-12-21 at 18:38 -0800, Luis R. Rodriguez wrote:
> A linker table is a data structure that is stitched together from
> items
> in multiple object files. Linux has historically implicitly used
> linker
> tables for ages, however they were all built in an adhoc manner which
> requires linker script modifications, per architecture. This adds a
> general linker table solution so that a new linker table can be
> implemented by changing C code only. The Linux linker table was
> inspired by Michael Brown's iPXE's linker table solution, it has been
> been completely re-written and adapted for integration and use on
> Linux.




> +/**
> + * LINKTABLE_FOR_EACH - iterate through all entries within a linker
> table
> + *
> + * @pointer: entry pointer
> + * @tbl: linker table
> + *
> + * Example usage::
> + *
> + *   struct frobnicator *frob;
> + *
> + *   LINKTABLE_FOR_EACH(frob, frobnicator_fns) {
> + *     ...
> + *   }
> + */
> +
> +#define LINKTABLE_FOR_EACH(pointer, tbl)				
> \

Hmm... SOMEONE LIKES CAPITAL LETTERS FOR everything, right? :-)

I would expect more standard 
linktable_for_each()
macro

Same to the rest of similar macros.


> +/**
> + * LINKTABLE_RUN_ERR - run each linker table entry func and return
> error if any
> + *
> + * @tbl: linker table
> + * @func: structure name for the function name we want to call.
> + * @args...: arguments to pass to func
> + *
> + * Example usage::
> + *
> + *   unsigned int err = LINKTABLE_RUN_ERR(frobnicator_fns,
> some_run,);
> + */
> +#define LINKTABLE_RUN_ERR(tbl, func, args...)				
> \
> +({									
> \
> +	size_t i;							
> \
> +	int err = 0;							
> \
> +	for (i = 0; !err && i < LINKTABLE_SIZE(tbl); i++)		
> \
> +		err = (LINKTABLE_START(tbl)[i]).func (args);		


> \
> +		err;							

Indentation here a bit confusing.

> \
> +})


-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
