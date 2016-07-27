From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Wed, 27 Jul 2016 22:55:03 +0000
Subject: Re: [RFC v3 10/13] jump_label: port __jump_table to linker tables
Message-Id: <20160727225503.GP5537@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1469222687-1600-1-git-send-email-mcgrof@kernel.org>
 <1469222687-1600-11-git-send-email-mcgrof@kernel.org>
 <20160722214945.h7v7fvsnuhnvz6ux@treble>
 <20160722222654.GO5537@wotan.suse.de>
 <20160722225535.uu7h7iowwchby7uy@treble>
In-Reply-To: <20160722225535.uu7h7iowwchby7uy@treble>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, ciaran.farrell@suse.com, christopher.denicolo@suse.com, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix.com, andriy.shevche

On Fri, Jul 22, 2016 at 05:55:35PM -0500, Josh Poimboeuf wrote:
> On Sat, Jul 23, 2016 at 12:26:54AM +0200, Luis R. Rodriguez wrote:
> > On Fri, Jul 22, 2016 at 04:49:45PM -0500, Josh Poimboeuf wrote:
> > > On Fri, Jul 22, 2016 at 02:24:44PM -0700, Luis R. Rodriguez wrote:
> > > > diff --git a/tools/objtool/special.c b/tools/objtool/special.c
> > > > index bff8abb3a4aa..f0ad369f994b 100644
> > > > --- a/tools/objtool/special.c
> > > > +++ b/tools/objtool/special.c
> > > > @@ -26,6 +26,10 @@
> > > >  #include "special.h"
> > > >  #include "warn.h"
> > > >  
> > > > +#include "../../include/asm-generic/sections.h"
> > > > +#include "../../include/asm-generic/tables.h"
> > > > +#include "../../include/linux/stringify.h"
> > > > +
> > > >  #define EX_ENTRY_SIZE		12
> > > >  #define EX_ORIG_OFFSET		0
> > > >  #define EX_NEW_OFFSET		4
> > > > @@ -63,7 +67,9 @@ struct special_entry entries[] = {
> > > >  		.feature = ALT_FEATURE_OFFSET,
> > > >  	},
> > > >  	{
> > > > -		.sec = "__jump_table",
> > > > +		.sec = __stringify(SECTION_TBL(SECTION_DATA,
> > > > +				               __jump_table,
> > > > +					       SECTION_ORDER_ANY)),
> > > >  		.jump_or_nop = true,
> > > >  		.size = JUMP_ENTRY_SIZE,
> > > >  		.orig = JUMP_ORIG_OFFSET,
> > > 
> > > (continuing our discussion from another thread...)
> > > 
> > > I think tools code isn't allowed to include kernel files because the
> > > tools subdirectory is supposed to be completely independent.
> > 
> > That was also the case for userpsace tools in scripts/ -- for instance
> > scripts/mod/modpost.c made an exception. What I've proposed here to
> > keep things simple was to ensure -UKERNEL is passed and then only
> > include files we know will work.
> > 
> > Refer to the patch "kprobes: port .kprobes.text to section range"
> > in this series for an extension of the scripts/mod/modpost.c kernel
> > headers use.
> 
> I think the rule of separating code is stricter for tools/ than it is
> for scripts/.  The scripts are generally kernel-specific whereas the
> tools are independent.  I believe the goal is to be able to copy them
> out of the kernel tree and still be able to compile them.

I see.

> > > As far as I can tell, the section name will always be
> > > ".data.tbl.__jump_table.any".  Is that true?  If so, any reason why we
> > > can't just hard-code the string here?
> > 
> > Its a fair strategy, however if upstream changes the order name we'd
> > have to hand code this as well, by using a macro we keep it all in one
> > place.
> 
> Hm, do you expect the section name to change often?

Nope, if anything only upon deployment on major distributions due to
some perhaps compatibility thing with custom hacks folks may have carried
and this just ended up clashing with. The only other case I can think
of a need for a change would be if upstream linkers supported something
similar for another brand of section names, with the added gain that
we would then not even need the 2 new lines on the kernel linker script
for section ranges and tables per section.

> > > As you saw, if the string
> > > changes, objtool will complain and 0-day will report it.
> > 
> > Indeed, which is why I was hoping to instead stick to a standard
> > sections set of header files that lets us get these in on place.
> 
> Actually, I meant that obtool reporting the change would be a good
> thing, in favor of just hard-coding the string.  It lets objtool do its
> job of letting us know when something changes, like it did today.

Getting a report so you can fix something is one reason to have a tool,
having it so you can inspect changes is another. So it depends what uses
there are for objtool. I take it that for this case we do want upstream
objtool to embrace the new section name to avoid further reports as
issues ?

> > The only place I hand coded in this series was in the perl
> > file scripts/recordmcount.pl but I suppose if we wanted to get
> > creative we could even generate a header for it too.
> > 
> > If we want to avoid all this hacker include stuff another option
> > is to *generate* each respective sections.h for the kernel, and
> > also, one for tools, and one for perl. What do you think?
> 
> If the generated files aren't checked into git, tools/ will rely on
> kernel files and will no longer be independent.  If they *are* checked
> in, then we have to keep the files in sync.  Either way it sounds like
> overkill, just to avoid hard-coding a string for which objtool will
> already warn if it changes.

We can open code the string, that's fine. In retrospect since things
won't change often that keeps things simple.

  Luis
