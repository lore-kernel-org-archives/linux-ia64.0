From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 23 Aug 2016 00:28:42 +0000
Subject: Re: [PATCH v1 7/7] tools: add userspace linker table sandbox
Message-Id: <201608230028.u7N0SneR020502@mail.zytor.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org> <1471642875-5957-1-git-send-email-mcgrof@kernel.org> <1471642875-5957-8-git-send-email-mcgrof@kernel.org> <CAGXu5jKX-VZR_r9wMsnLAU+Z10vB4yDiRPpvwXbRZj0=wU208A@mail.gmail.com> <20160823000739.GX3296@wotan.suse.de>
In-Reply-To: <20160823000739.GX3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, mhiramat@kernel.org, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, jbaron@akamai.com, Heiko Carstens <heiko.carstens@de.ibm.com>, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, "David S. Miller" <davem@davemloft.net>, Miao Steven <realmz6@gmail.com>, "x86@kernel.org" <x86@kernel.org>, Andy Lutomirski <luto@amacapital.net>, Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Rusty Russell <rusty@rustcorp.com.au>, "gnomes@lxorguk.ukuu.org.uk" <gnomes@lxorguk.ukuu.org.uk>, Alan Cox <alan@linux.intel.com>, David Woodhouse <dwmw2@infradead.org>, Arnd

Vrabel <david.vrabel@citrix.com>,Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,Michael Brown <mcb30@ipxe.org>,Juergen Gross <jgross@suse.com>,Andrew Cooper <andrew.cooper3@citrix.com>,Andy Shevchenko <andriy.shevchenko@linux.intel.com>,Paul Gortmaker <paul.gortmaker@windriver.com>,"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,Andi Kleen <ak@linux.intel.com>,pali.rohar@gmail.com,dvhart@infradead.org,platform-driver-x86@vger.kernel.org,Michal Marek <mmarek@suse.com>,Rasmus Villemoes <linux@rasmusvillemoes.dk>,Jiri Kosina <jkosina@suse.cz>,=?UTF-8?B?7KGw6rK966+8?= <korea.drzix@gmail.com>,linux-kbuild <linux-kbuild@vger.kernel.org>,Tony Luck <tony.luck@intel.com>,Andrew Morton <akpm@linux-foundation.org>,linux-ia64@vger.kernel.org,"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,linux-sh <linux-sh@vger.kernel.org>,sparclinux <sparclinux@vger.kernel.org>,Catalin Marinas <catalin.marinas@arm.com>,Will Deacon <will.deacon@arm.com>,Ste!
 ven
Rostedt <rostedt@goodmis.org>,Jani Nikula <jani.nikula@intel.com>,Mauro Carvalho Chehab <mchehab@osg.samsung.com>,markus.heiser@darmarit.de,jolsa@kernel.org,Mark Salter <msalter@redhat.com>,Chris Zankel <chris@zankel.net>,Max Filippov <jcmvbkbc@gmail.com>,linux-xtensa@linux-xtensa.org,Paul Mackerras <paulus@samba.org>,Michael Ellerman <mpe@ellerman.id.au>,James Bottomley <James.Bottomley@hansenpartnership.com>
Message-ID: <58F06CEA-AEB3-4ED7-8211-95F402C9D3D3@zytor.com>

On August 22, 2016 5:07:39 PM PDT, "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
>On Fri, Aug 19, 2016 at 03:31:47PM -0700, Kees Cook wrote:
>> On Fri, Aug 19, 2016 at 2:41 PM,  <mcgrof@kernel.org> wrote:
>> > From: "Luis R. Rodriguez" <mcgrof@kernel.org>
>> >
>> > Add a userspace sandbox to allow easy experimentation and
>> > test extensions with linker tables, section ranges and the
>> > new section core definitions.
>> >
>> > The userspace sandbox tries to mimic the Linux kernel development
>> > flow as much as possible, it however relies on and uses libc.
>Support
>> > is currently only provided to x86_64.
>> >
>> > v4: this patch is new in this series -- added to the kenrel as
>> >     suggested by Boris, as otherwise it'd be really hard to keep
>> >     an external userspace repository in sync.
>> >
>> > Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>
>> > ---
>> >  Documentation/sections/linker-tables.rst           |   4 +-
>> >  MAINTAINERS                                        |   1 +
>> >  include/linux/tables.h                             |   5 +-
>> >  tools/Makefile                                     |   3 +-
>> >  .../arch/x86/include/generated/asm/section-core.h  |   1 +
>> >  tools/arch/x86/include/generated/ranges.h          |   1 +
>> >  tools/arch/x86/include/generated/tables.h          |   1 +
>> >  tools/include/asm-generic/ranges.h                 | 103 ++++
>> >  tools/include/asm-generic/section-core.h           | 341
>+++++++++++
>> >  tools/include/asm-generic/tables.h                 |  50 ++
>> 
>> Aren't a bunch of these files exact duplicates of the headers in
>include/linux?
>
>Indeed... This a userspace tools/ architecture decision that was made
>long ago,
>so its not up to me, I am just following the strategy devised and
>picked up.
>Refer to 7d7d1bf1d1dabe435ef50efb051724b8664749cb ("perf bench: Copy
>kernel
>files needed to build mem{cpy,set} x86_64 benchmarks") for an example
>of
>previous similar work. By sharing header files this enable more tools/
>to be hacked on.
>
>  Luis

I think this is a legacy from before the uapi change that should really be fixed.  If we need to export additional kernel structures for the tools, we could define a third level of we really need it.
-- 
Sent from my Android device with K-9 Mail. Please excuse brevity and formatting.
