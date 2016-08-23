From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Tue, 23 Aug 2016 16:31:05 +0000
Subject: Re: [PATCH v4 14/16] kprobes: move kprobe declarations to asm-generic/kprobes.h
Message-Id: <20160823163104.GZ3296@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <1471642454-5679-15-git-send-email-mcgrof@kernel.org>
 <20160823001140.8f7293408d2094a14c7725a1@kernel.org>
In-Reply-To: <20160823001140.8f7293408d2094a14c7725a1@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masami Hiramatsu <mhiramat@kernel.org>
Cc: mcgrof@kernel.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.c

On Tue, Aug 23, 2016 at 12:11:40AM +0900, Masami Hiramatsu wrote:
> On Fri, 19 Aug 2016 14:34:12 -0700
> mcgrof@kernel.org wrote:
> 
> > From: "Luis R. Rodriguez" <mcgrof@kernel.org>
> > 
> > Often all is needed is these small helpers, instead of compiler.h
> > or a full kprobes.h. This is important for asm helpers, in fact even
> > some asm/kprobes.h make use of these helpers... instead just keep a
> > generic asm file with helpers useful for asm code with the least amount
> > of clutter as possible.
> > 
> > Likewise we need now to also address what to do about this file for both
> > when architectures have CONFIG_HAVE_KPROBES, and when they do not. Then
> > for when architectures have CONFIG_HAVE_KPROBES but have disabled
> > CONFIG_KPROBES.
> > 
> > Right now most asm/kprobes.h do not have guards against CONFIG_KPROBES,
> > this means most architecture code cannot include asm/kprobes.h safely.
> > Correct this and add guards for architectures missing them. Additionally
> > provide architectures that not have kprobes support with the default
> > asm-generic solution. This lets us force asm/kprobes.h on the header
> > include/linux/kprobes.h always, but most importantly we can now safely
> > include just asm/kprobes.h on architecture code without bringing
> > the full kitchen sink of header files.
> > 
> > Two architectures already provided a guard against CONFIG_KPROBES on
> > its kprobes.h: sh, arch. The rest of the architectures needed gaurds
> > added. We avoid including any not-needed headers on asm/kprobes.h
> > unless kprobes have been enabled.
> > 
> > In a subsequent atomic change we can try now to remove compiler.h from
> > include/linux/kprobes.h.
> 
> Hmm, this looks a bit overkill... I rather like move it into linux/table.h.

That's the thing, we can't reasonably expect every table to add an entry into
table.h, this should be up to each user. Moving it to tables.h just prolongs
what needs to be done. In this case the change is justifiable given kprobe
annotations are required for some architectures early in architecture code, and
including compiler.h on early architecture code blows up. There is no easy fix
to this, and this this was *actually* the cleanest solution I could devise
without much changes.

  Luis
