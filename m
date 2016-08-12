From: Borislav Petkov <bp@alien8.de>
Date: Fri, 12 Aug 2016 15:51:21 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160812155121.GB13315@nazgul.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
 <20160729100630.GA27271@nazgul.tnic>
 <20160808150539.GG3296@wotan.suse.de>
 <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
 <20160812065011.GB3296@wotan.suse.de>
 <20160812072507.GC12013@nazgul.tnic>
 <20160812152805.GD3296@wotan.suse.de>
In-Reply-To: <20160812152805.GD3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.com, xen-

On Fri, Aug 12, 2016 at 05:28:05PM +0200, Luis R. Rodriguez wrote:
> Even so, you don't link the compiled extra code so the only penalty
> here is when compiling, nothing more. And if you are compiling typically
> the cost here is just a few seconds.

Yeah, so let's make it clear that this is similar to COMPILE_TEST and
people with fast machines and who don't mind building a couple more
seconds longer, should enable it.

You don't want to be doing bit-rotting tests on small, weak machines,
which barely get done with the build as it is. I have a 32-bit atom
which takes hours to build a kernel. Enabling that there is not making
the kernel build any more fun.

> > ... or you simply don't want to have stuff which is forcibly enabled on you even
> > if you're never going to need it
> > ...
> 
> Which seems to be the same as the reason I noted ?

No, the reason is we don't force stuff down people's throats just
because we think we know better. Other people do that.

Instead, we help them make an informed decision by describing the
feature as precisely as possible.

> I can remove the grumpy maintainer description :)

Yap :-)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--
