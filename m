From: Greg KH <gregkh@linuxfoundation.org>
Date: Sat, 13 Aug 2016 10:46:16 +0000
Subject: Re: [RFC v3 07/13] tables.h: add linker table support
Message-Id: <20160813104616.GA16348@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160809035508.GC11445@nazgul.tnic>
 <20160812035129.GA3296@wotan.suse.de>
 <20160812052303.GB12013@nazgul.tnic>
 <20160812065011.GB3296@wotan.suse.de>
 <20160812072507.GC12013@nazgul.tnic>
 <20160812152805.GD3296@wotan.suse.de>
 <20160812155121.GB13315@nazgul.tnic>
 <20160812170451.GE3296@wotan.suse.de>
 <20160812202334.GA10199@kroah.com>
 <20160812220042.GF3296@wotan.suse.de>
In-Reply-To: <20160812220042.GF3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevchenko@linux.intel.com, paul.gortmaker@windriver.comx

On Sat, Aug 13, 2016 at 12:00:42AM +0200, Luis R. Rodriguez wrote:
> On Fri, Aug 12, 2016 at 10:23:34PM +0200, Greg KH wrote:
> > On Fri, Aug 12, 2016 at 07:04:52PM +0200, Luis R. Rodriguez wrote:
> > > Alright, how's this new description:
> > > 
> > > diff --git a/init/Kconfig b/init/Kconfig
> > > index cac3f096050d..73e4890c24c4 100644
> > > --- a/init/Kconfig
> > > +++ b/init/Kconfig
> > > @@ -53,6 +53,34 @@ config CROSS_COMPILE
> > >  	  need to set this unless you want the configured kernel build
> > >  	  directory to select the cross-compiler automatically.
> > >  
> > > +config BUILD_AVOID_BITROT
> > > +	bool "Always force building specially annotated targets"
> > > +	default n
> > > +	help
> > > +	  If enabled then the the special table-* Makefile targets will always
> > > +	  be forced to be compiled even if their respective CONFIG_ option has
> > > +	  been disabled, but its objects will only be linked in if the same
> > > +	  respective CONFIG_ option has been enabled. This helps avoid code
> > > +	  bit rot issues, use for these targets should be carefully considred
> > > +	  by maintainers. You can safely enable this option at the expense of
> > > +	  increasing compile time. Enabling this option helps avoid code bit
> > > +	  rot by taking advantage of the facilities provided and enabled by
> > > +	  using linker tables documented under:
> > 
> > As a kernel developer I have _no_ idea what this is trying to say at
> > all, sorry.
> 
> Hmm, wow OK, sorry, and I thought I was being too verbose...

All of your good explainations and detail need to go into the text
itself.  Responding to my questions is wonderful, but is not going to
help anyone out who sees the config option for the first time, unless
you change the text there.

> OK so first, linker tables allow for the ability to help simplify initialization
> sequences so that you no longer have to add the respective static inline in
> header files to do nothing, instead you simply get your init routine for your
> feature pegged into the linker table or not at link time. If enabling your
> feature does not require structural changes, you could then safely enable
> compiling this feature all the time, and only allow linking when the feature
> was enabled. We don't have an easy way to express this in our build system,
> the new targets added lets you accomplish this.

I still don't understand, sorry.

As a kernel developer, why do I care about this?  Who should care about
this, a driver developer, subsystem developer, someone adding a syscall,
an arch subsystem developer?

> > What is a "specially annotated target"?
> 
> The ones listed below, table-obj-y and table-lib-y

circular logic doesn't work :)

> > Who is forcing it to be built?
> 
> It would be up to maintainers for each subsystem/feature to decide if they want
> to use the new targets or not within their subsystem.

Ok, as a maintainer of a subsystem, I still have no idea what any of
this means.  But maybe I'm just don't understand kernel subsystem
development...

> > What does it mean if it isn't built?
> 
> If you have CONFIG_BUILD_AVOID_BITROT enabled and some code using the special
> targets do not get built it means the dependencies it has were not met.

What "dependencies"?

> > > +
> > > +	  include/linux/tables.h
> > > +
> > > +	  The special targets supported are:
> > > +
> > > +	    o table-obj-y
> > > +	    o table-lib-y
> > 
> > What does this mean to me as a developer?
> 
> It mean you can count on a bit more build test coverage by
> CONFIG_BUILD_AVOID_BITROT users. Using table-obj-y is functionally
> equivalent to doing:
> 
> extra-y += foo.o
> obj-y += foo.o

Ok, but why change this?  What's the advantage?  Are you going to now go
and change all locations of the above in the tree to the table-
versions?  If not, why is this needed?

> The above new targets are just short hand annotations for the same.  We could
> actually use another shorthand prefix other than table-, however linker tables
> help making more of these type of targets possible. For instance, on initialiation
> sequences you no longer have to add each line for each feature onto a set routine,
> rather you just get the initialization routine linked in or not. This lets us avoid
> cluttering C code and header code with #idefs, and as a side consequences also
> allows more targets to be compiled without implicating functionality.
> 
> As a developer you should take care to to use table-obj-y, or table-lib-y only if
> you are certain the target does not require structural changes.

How am I supposed to be "certain"?

> > What does it mean to a user
> > who wants to figure out if it should be enabled or not?
> 
> It depends on their build system capability and their goals. If they wish
> to be able to report build bugs and have a decent build system they can
> enable this. Otherwise they should disable it.

Why is this differnent from CONFIG_TEST build option we have today (or
whatever it's called...)

Anyway, again, I have no idea what this is, nor how I should use it.
And if I am the audience for this type of config option, well, perhaps
it needs to be rethought...

thanks,

greg k-h
