From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 12 Aug 2016 17:04:52 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160812170451.GE3296@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-8-git-send-email-mcgrof@kernel.org>
 <20160729100630.GA27271@nazgul.tnic>
 <20160808150539.GG3296@wotan.suse.de>
 <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
 <20160812065011.GB3296@wotan.suse.de>
 <20160812072507.GC12013@nazgul.tnic>
 <20160812152805.GD3296@wotan.suse.de>
 <20160812155121.GB13315@nazgul.tnic>
In-Reply-To: <20160812155121.GB13315@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel

On Fri, Aug 12, 2016 at 05:51:21PM +0200, Borislav Petkov wrote:
> On Fri, Aug 12, 2016 at 05:28:05PM +0200, Luis R. Rodriguez wrote:
> > Even so, you don't link the compiled extra code so the only penalty
> > here is when compiling, nothing more. And if you are compiling typically
> > the cost here is just a few seconds.
> 
> Yeah, so let's make it clear that this is similar to COMPILE_TEST and
> people with fast machines and who don't mind building a couple more
> seconds longer, should enable it.

Sure, I'll also move it under COMPILE_TEST, and default it to n.

> You don't want to be doing bit-rotting tests on small, weak machines,
> which barely get done with the build as it is. I have a 32-bit atom
> which takes hours to build a kernel. Enabling that there is not making
> the kernel build any more fun.
> 
> > > ... or you simply don't want to have stuff which is forcibly enabled on you even
> > > if you're never going to need it
> > > ...
> > 
> > Which seems to be the same as the reason I noted ?
> 
> No, the reason is we don't force stuff down people's throats just
> because we think we know better. Other people do that.
> 
> Instead, we help them make an informed decision by describing the
> feature as precisely as possible.
> 
> > I can remove the grumpy maintainer description :)
> 
> Yap :-)

Alright, how's this new description:

diff --git a/init/Kconfig b/init/Kconfig
index cac3f096050d..73e4890c24c4 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -53,6 +53,34 @@ config CROSS_COMPILE
 	  need to set this unless you want the configured kernel build
 	  directory to select the cross-compiler automatically.
 
+config BUILD_AVOID_BITROT
+	bool "Always force building specially annotated targets"
+	default n
+	help
+	  If enabled then the the special table-* Makefile targets will always
+	  be forced to be compiled even if their respective CONFIG_ option has
+	  been disabled, but its objects will only be linked in if the same
+	  respective CONFIG_ option has been enabled. This helps avoid code
+	  bit rot issues, use for these targets should be carefully considred
+	  by maintainers. You can safely enable this option at the expense of
+	  increasing compile time. Enabling this option helps avoid code bit
+	  rot by taking advantage of the facilities provided and enabled by
+	  using linker tables documented under:
+
+	  include/linux/tables.h
+
+	  The special targets supported are:
+
+	    o table-obj-y
+	    o table-lib-y
+
+	  Say Y if you have a decent build machine and would like to help test
+	  building code for more subsystems. Say N if you do you not have a
+	  good build machine or only want to compile what you've enabled for
+	  your kernel.
+
+	  Enabling this option never increases the size of your kernel.
+
 config COMPILE_TEST
 	bool "Compile also drivers which will not load"
 	depends on !UML
