From: Greg KH <gregkh@linuxfoundation.org>
Date: Thu, 19 Jan 2017 11:11:50 +0000
Subject: Re: [PATCH v7 03/14] ranges.h: add helpers to build and identify Linux section ranges
Message-Id: <20170119111150.GI28024@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170109145833.11502-1-mcgrof@kernel.org>
 <20170115211057.17167-1-mcgrof@kernel.org>
 <20170115211057.17167-4-mcgrof@kernel.org>
In-Reply-To: <20170115211057.17167-4-mcgrof@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: bp@alien8.de, bp@suse.de, hpa@zytor.com, acme@redhat.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, npiggin@gmail.com, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, dalias@libc.org, linux@arm.linux.org.uk, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, linux@roeck-us.net, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org

On Sun, Jan 15, 2017 at 01:10:46PM -0800, Luis R. Rodriguez wrote:
> Section ranges are on one of the types of custom sections
> types used in Linux.

Argh, come on, proof-read your changelog text please!

> This provides a series of helpers for
> defining them and using them. Most importantly this also
> enables us to avoid modifying the linker script when we
> add a new section range.

Also pick a line width and stick to it!

> It turns out a lot of custom sections are actually section ranges,
> and these are typically spelled out in their architecture specific
> asm/sections.h file -- we enable architectures to override what asm
> is used for section ranges but start by default trusting the
> asm-generic version all around.
> 
> Although typically you will not want to have section ranges ordered
> we must use SORT() on vmlinux.lds.S for section ranges to enable us
> to extend a section range without modifying the linker script. To
> accomplish this we use a special order string for the first element of a
> section range -- the empty string "" (refer to __SECTION_RANGE_BEGIN()),
> then "~" for the last element (refer to __SECTION_RANGE_BEGIN()). If
> you use the "any" order for elements in between and use SORT() you end
> up keeping any added element in between and a reference to the
> beginning and end of the section range without requiring custom linker
> script modifications. Specific order annotations are also supported
> to help construct synthetic functions, a demo for which will be provided
> later.

Again, split your documentation from your coding changes to make it
easier to review one or the other.

thanks,

greg k-h
