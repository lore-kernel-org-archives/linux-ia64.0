From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 26 Aug 2016 13:28:55 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160826232855.31464a63@roar.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160823173306.GA3296@wotan.suse.de>
        <20160824135141.2c8f06ec@roar.ozlabs.ibm.com>
        <20160824201253.GS3296@wotan.suse.de>
        <20160825120633.057b2f6f@roar.ozlabs.ibm.com>
        <20160825060540.GX3296@wotan.suse.de>
        <20160825165121.45d26fb0@roar.ozlabs.ibm.com>
        <20160825175239.GB3296@wotan.suse.de>
        <20160826130024.0ad51d33@roar.ozlabs.ibm.com>
        <CAB=NE6UQ8qE6AqRg9=YddNYrMyU7opCEij-5Usty7wMgEJJbpw@mail.gmail.com>
        <20160826173338.41a56103@roar.ozlabs.ibm.com>
        <20160826132219.GG3296@wotan.suse.de>
In-Reply-To: <20160826132219.GG3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: benh@kernel.crashing.org, jani.nikula@intel.com, masami.hiramatsu.pt@hitachi.com, linux@rasmusvillemoes.dk, linux-kbuild@vger.kernel.org, linux-sh@vger.kernel.org, luto@amacapital.net, gnomes@lxorguk.ukuu.org.uk, jcmvbkbc@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, dwmw2@infradead.org, xen-devel@lists.xensource.com, anil.s.keshavamurthy@intel.com, will.deacon@arm.com, linux-ia64@vger.kernel.org, x86@kernel.org, korea.drzix@gmail.com, mingo@redhat.com, andrew.cooper3@citrix.com, jgross@suse.com, tglx@linutronix.de, keescook@chromium.org, ananth@linux.vnet.ibm.com, jpoimboe@redhat.com, rostedt@goodmis.org, hpa@zytor.com, acme@redhat.com, arnd@arndb.de, davem@davemloft.net, platform-driver-x86@vger.kernel.org, jkosina@suse.cz, david.vrabel@citrix.com

On Fri, 26 Aug 2016 15:22:19 +0200
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> On Fri, Aug 26, 2016 at 05:33:38PM +1000, Nicholas Piggin wrote:
> > On Thu, 25 Aug 2016 23:38:44 -0700
> > "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:  
> > > > > > > Ah, thing is we use this for both linktables and section ranges.
> > > > > > > Or do we want macros for both that do the same thing ?    
> > > > > >
> > > > > > I think it would make the code using it more readable.    
> > > > >
> > > > > Alrighty... so:
> > > > >
> > > > > LINKTABLE_START()
> > > > > LINKTABLE_END()
> > > > >
> > > > > SECTION_RANGE_START()
> > > > > SECTION_RANGE_END()
> > > > >
> > > > > And these macros do the exact same thing. Ie, nothing shared. Right?    
> > > >
> > > > Yeah I think so. Internally they would probably be aliased to the
> > > > same common definition (unless you had some type check or something),
> > > > but user would know about such details.    
> > > 
> > > What name should we use for such common macro definition ?  
> > 
> > 
> > Ah, not really sure. I guess the "link table" is some kind of
> > section range? I haven't actually looked closely at both of them
> > in the subsequent patches. It matters less if it's not expected
> > to be used as an API though.
> >   
> 
> OK well, going with LINUX_SECTION_START() so we'll have:
> 
> #define LINKTABLE_START		LINUX_SECTION_START
> #define LINKTABLE_END		LINUX_SECTION_END
> 
> #define SECTION_RANGE_START	LINUX_SECTION_START
> #define SECTION_RANGE_END	LINUX_SECTION_END
> 
> Is that OK?

I guess so, without having seen the updated, although I don't see why
you'd not just

#define LINKTABLE_START SECTION_RANGE_START
