From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 15 Aug 2016 22:40:14 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <1471300814.2428.45.camel@HansenPartnership.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
	 <20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
	 <1470758947.2299.47.camel@HansenPartnership.com>
	 <CALCETrVmDhPC6BMu4_xTanSFZBKeW9V6A4SeQ4qxnpVod-eLbQ@mail.gmail.com>
	 <1471292106.5944.3.camel@linux.intel.com>
In-Reply-To: <1471292106.5944.3.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Cox <alan@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>
Cc: benh@kernel.crashing.org, masami.hiramatsu.pt@hitachi.com, linux@rasmusvillemoes.dk, linux-kbuild@vger.kernel.org, linux-sh@vger.kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dwmw2@infradead.org, xen-devel@lists.xensource.com, "Luis R. Rodriguez" <mcgrof@kernel.org>, anil.s.keshavamurthy@intel.com, will.deacon@arm.com, linux-ia64@vger.kernel.org, x86@kernel.org, korea.drzix@gmail.com, mingo@redhat.com, andrew.cooper3@citrix.com, jgross@suse.com, tglx@linutronix.de, keescook@chromium.org, ananth@linux.vnet.ibm.com, jpoimboe@redhat.com, rostedt@goodmis.org, hpa@zytor.com, arnd@arndb.de, davem@davemloft.net, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, platform-driver-x86@vger.kernel.org, jkosina@suse.cz, david.vrabel@citrix.com, realmz6@gmail.com, fontana@sharpeleven.org, konrad.wilk@oracle.com, ananth@in.ibm.com, paul.gortmaker@windriver.c

On Mon, 2016-08-15 at 21:15 +0100, Alan Cox wrote:
> > This is the module tag ... it says what licence the module is 
> > under, not the licence for the module combined with the kernel, 
> > which is always GPLv2 because the stricter licence rules.
> 
> Because if I build a BSD licensed module against the kernel, give you
> the binaries and refuse to give you the source I am conforming to the
> BSD licence in letter.

No, you can't.  Forget dual licensing for a minute: I can produce a
Linux kernel module under a pure BSD licence because BSD is compatible
with GPL.  However, if we assume for the sake of argument that a binary
module is a derived work of Linux, producing and distributing the
binary for the module brings the combination under GPLv2 via the
derivative works clause and I'm required to offer you corresponding
source code in spite of the fact that my module *only* has a BSD
licence.  The only known get out from this is if I make *you* produce
the binary (the open source shim defence).

>  So to use it with the kernel it needs to be GPL with additional
> rights (eg BSD including the source...)

I'm not quite sure what you're disagreeing over?  Is it semantics of a
Dual BSD/GPL licence vs a GPL with additional rights one?  Dual
licensed code is a well settled area: the ruling licence is the one
which permits the action.  So for a dual licencesed kernel module, if I
compile the module as a binary and distribute it, I'm required to
follow all the provisions of GPLv2 i.e. make you and offer of
corresponding source.   Conversely, if I cut and paste a section of the
driver source code into a BSD driver, I'm permitted to do this under
the BSD licence, so the pasted code doesn't carry GPLv2 contamination
into BSD.

You can certainly call the Dual BSD/GPL licence a GPL licence with
additional permission to include the source code in a BSD licensed
system, but it's not a precise equivalence because a true Dual Licensed
BSD/GPL driver may be cut and pasted into any code which is compatible
either with the BSD or GPL licences, meaning it's actually less strict
than your additional permission to include into BSD.

James

