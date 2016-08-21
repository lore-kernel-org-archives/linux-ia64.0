From: Rich Felker <dalias@libc.org>
Date: Sun, 21 Aug 2016 04:59:59 +0000
Subject: Re: [PATCH v1 0/7] tools: add linker table userspace sandbox
Message-Id: <20160821045959.GR15995@brightrain.aerifal.cx>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
 <1471642875-5957-1-git-send-email-mcgrof@kernel.org>
 <ef5f6b3f-1b00-d33f-4ce1-81e03f4f2f10@landley.net>
In-Reply-To: <ef5f6b3f-1b00-d33f-4ce1-81e03f4f2f10@landley.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rob Landley <rob@landley.net>
Cc: mcgrof@kernel.org, acme@redhat.com, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jg

On Fri, Aug 19, 2016 at 11:57:18PM -0500, Rob Landley wrote:
> On 08/19/2016 04:41 PM, mcgrof@kernel.org wrote:
> > Please let me know if there are any issue or questions.
> 
> Only that this has been the majority of the traffic on the linux-sh
> mailing list for over a month and I'm still not sure why anyone should care.
> 
> I have no idea what problem it solves, despite reading a couple dozen
> messages in the thread, and the most recent two 0/x intro messages. Its
> purpose seems to be ensuring that lld.llvm.org has more work to do if it
> ever wants to build the kernel without binutils?
> 
> I also am not certain why every revision of it is cc'd to linux-sh. Is
> it generic linker infrastructure change, or is it something that affects
> this architecture specifically? As far as I can tell nothing in this
> most recent 7-patch series touches arch/sh at all, you just cc'd our
> list because you think the work you're doing is _important_, not that
> it's specifically relevant to us.

Incidentally I'm happy to have been CC'd since this infrastructure is
_really_ nice for doing things generically with device tree. The
ability to add new linker-section-based tables without having to
manually hack up linker script templates will make it so we can do
things like adding tables for cache controllers or mmus (that are
needed quite early in init and can't go through the platform device
system).

BTW we kinda lucked out that there was already the linker table
infrastructure for cpu enable methods for smp; this patch series makes
it so future stuff doesn't have to rely on luck or invasive changes.

Rich
