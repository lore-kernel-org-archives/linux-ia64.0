From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Fri, 26 Aug 2016 13:22:19 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160826132219.GG3296@wotan.suse.de>
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
In-Reply-To: <20160826173338.41a56103@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Piggin <npiggin@gmail.com>
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, realmz6@gmail.com, linux-sh@vger.kernel.org, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, linux@rasmusvillemoes.dk, platform-driver-x86@vger.kernel.org, James.Bottomley@hansenpartnership.com, jcmvbkbc@gmail.com, paulus@samba.org, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, msalter@redhat.com, davem@davemloft.net, mpe@ellerman.id.au, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, mhiramat@kernel.org, linux-xtensa@linux-xtensa.org, rusty@rustcorp.com.au, keescook@chromium.org, arnd@arndb.de, linux-kbuild@vger.kernel.org, jani.nikula@int

On Fri, Aug 26, 2016 at 05:33:38PM +1000, Nicholas Piggin wrote:
> On Thu, 25 Aug 2016 23:38:44 -0700
> "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
> > > > > > Ah, thing is we use this for both linktables and section ranges.
> > > > > > Or do we want macros for both that do the same thing ?  
> > > > >
> > > > > I think it would make the code using it more readable.  
> > > >
> > > > Alrighty... so:
> > > >
> > > > LINKTABLE_START()
> > > > LINKTABLE_END()
> > > >
> > > > SECTION_RANGE_START()
> > > > SECTION_RANGE_END()
> > > >
> > > > And these macros do the exact same thing. Ie, nothing shared. Right?  
> > >
> > > Yeah I think so. Internally they would probably be aliased to the
> > > same common definition (unless you had some type check or something),
> > > but user would know about such details.  
> > 
> > What name should we use for such common macro definition ?
> 
> 
> Ah, not really sure. I guess the "link table" is some kind of
> section range? I haven't actually looked closely at both of them
> in the subsequent patches. It matters less if it's not expected
> to be used as an API though.
> 

OK well, going with LINUX_SECTION_START() so we'll have:

#define LINKTABLE_START		LINUX_SECTION_START
#define LINKTABLE_END		LINUX_SECTION_END

#define SECTION_RANGE_START	LINUX_SECTION_START
#define SECTION_RANGE_END	LINUX_SECTION_END

Is that OK?

  Luis
