From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 27 Jul 2016 22:46:09 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <20160727224609.GO5537@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <20160725223229.7de71264e9e6ec8d635ee785@kernel.org>
In-Reply-To: <20160725223229.7de71264e9e6ec8d635ee785@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com

On Mon, Jul 25, 2016 at 10:32:29PM +0900, Masami Hiramatsu wrote:
> Hi Luis,
> 
> On Fri, 22 Jul 2016 14:24:34 -0700
> "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
> 
> > This RFC v3 builds off the last RFC v2 series [0] for adding linker tables.
> > The largest amount of work here was to take Russell King's feedback on
> > using linker table for kprobes text not being appropriate -- and providing
> > another lightweight API for simple section ranges: read-only stitched pieces
> > of executable code. This required also generalizing common building blocks
> > for both linker tables and section ranges, these building blocks are defined
> > now in include/linux/sections.h and asm-generic/section.h. The other last thing
> > decided was to not support sub-sections. In the hunt for this I could think of
> > anything that really required this, and if it was needed it did not seem
> > impossible to port over to avoid its use. Please let me know if there are valid
> > uses cases for sub-sections.
> > 
> > Other significant effort here was to provide a set of common assembly helpers
> > which could be used across architectures, this starts off some of this work
> > for generic helpers which carve out and define custom Linux sections.
> > 
> > Lastly, this now also goes with two ports which required module support when
> > using linker tables: jump labels, and dynamic debug support. A few
> > extensions have been made to the original series in order to provide
> > support for that.
> > 
> > Since kprobes actually had both a linker table and a section range the
> > patch that dealt with kprobes is now split off in two patches, one
> > that deals with its linker table and another for its section ranges.
> > 
> > More elaborate uses for linker tables are possible, I'll hold off on any
> > of this type of work until at least the basic building blocks are fleshed
> > out. To review how this work came about, and more elaborate uses being
> > evaluated check out the userspace linker-tables mockup solution [1].
> > Hopefully most of the possible bikeshedding was already dealt with through
> > that tree. Thanks to hpa for tons of feedback.
> 
> Great! so table and ranges completely replace the old-style(add-hoc)
> _kprobe and NOKPROBE_SYMBOL() implementation, good job! :)

Indeed, thanks! In reality this is generalizing custom section hacks, but also
making them much more powerful due to the fact that we sort now at link time,
this buys us better than O(1) sort for code where dependencies can be spelled
out in code, it also expands on the semantics available to us for order
levels -- so we're no longer restricted to 7 levels for built-in code -- and
order levels can be subject/subsystem specific.

  Luis
