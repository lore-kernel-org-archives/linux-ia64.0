From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 10 Aug 2016 17:03:29 +0000
Subject: Re: [RFC v3 00/13] linux: generalize sections, ranges and linker tables
Message-Id: <20160810170329.GK3296@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <20160809152429.5bb1c077@lxorguk.ukuu.org.uk>
 <1470758947.2299.47.camel@HansenPartnership.com>
In-Reply-To: <1470758947.2299.47.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, paul.gortmaker@windriver.com, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, linux-arch@vger.kernel.org, msalter@redhat.com, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, david.vrabel@citrix.com, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb.de, realmz6@gmail.com, a-jacquiot@ti.com, linux@rasmusvillemoes.dk, rusty@rustcorp.com.au, rostedt@goodmis.org, chris

On Tue, Aug 09, 2016 at 09:09:07AM -0700, James Bottomley wrote:
> On Tue, 2016-08-09 at 15:24 +0100, One Thousand Gnomes wrote:
> > > table development go under copyleft-next, Rusty recently asked for 
> > > code to go in prior to the license tag being added denoting this 
> > > license as GPL-compatible [3] -- I had noted in the patch 
> > > submission which annotated copyleft-next's compatibility to GPLv2 
> > > that copyleft-next is the license of choice for ongoing kernel 
> > > development on my end [4]. If this is objectionable I'm happy to 
> > > change it to GPLv2 however I'd like a reason provided as I've gone 
> > > through all possible channels to ensure this is kosher, including
> > > vetting by 3 attorneys now, 2 at SUSE.
> > 
> > You don't need a new tag, you can use "GPL" or "GPL and additional
> > rights". In fact you don't want any other tag because when combined
> >  with the kernel it is GPLv2 anyway because the only way the two are 
> > fully compatible is for the kernel community to license the derived 
> > work under the GPL.
> 
> This is the module tag ... it says what licence the module is under,
> not the licence for the module combined with the kernel, which is
> always GPLv2 because the stricter licence rules.

As per Linus' recommendations [0] if I add a module I'll be using
MODULE_LICENSE("GPL") if using copyleft-next. Either way this series
didn't add a module yet so no need for that yet, but it does use
copyleft-next in headers / C code.

[0] https://lkml.kernel.org/r/CA+55aFyhxcvD+q7tp+-yrSFDKfR0mOHgyEAe=f_94aKLsOu0Og@mail.gmail.com

> However, if I
> want my binary only modules to be combined with Linux, I have to follow
> GPLv2 compliance because GPLv2 becomes the ruling licence of the
> combination.  The same would apply to this copyleft-next, even after 15
> years.

And this what really matters here.

> The US copyright office defines a copyright work as anything which is
> "an original work of authorship fixed in any tangible medium of
> expression".  That means any change to an existing work (i.e. by a
> patch) which contains enough originality to make the changed work
> distinct from the old work is ipso facto a new work.  under copyright
> -next this new work has a sunset 15 years from its creation by
> combination, not 15 years from the original.  This means a constantly
> updated work never sunsets.  Sure, you can go back 15 years and claim
> the code at that time has passed into the public domain but you can't
> do that if you also want the benefit of later changes.

Agreed.

  Luis
