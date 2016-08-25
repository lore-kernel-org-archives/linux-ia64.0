From: Nicholas Piggin <npiggin@gmail.com>
Date: Thu, 25 Aug 2016 06:51:21 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160825165121.45d26fb0@roar.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
        <1471642454-5679-5-git-send-email-mcgrof@kernel.org>
        <20160823112633.7d482e62@roar.ozlabs.ibm.com>
        <20160823173306.GA3296@wotan.suse.de>
        <20160824135141.2c8f06ec@roar.ozlabs.ibm.com>
        <20160824201253.GS3296@wotan.suse.de>
        <20160825120633.057b2f6f@roar.ozlabs.ibm.com>
        <20160825060540.GX3296@wotan.suse.de>
In-Reply-To: <20160825060540.GX3296@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, jpoimboe@redhat.com, bp@alien8.de, linux@arm.linux.org.uk, mhiramat@kernel.org, masami.hiramatsu.pt@hitachi.com, jbaron@akamai.com, heiko.carstens@de.ibm.com, ananth@linux.vnet.ibm.com, anil.s.keshavamurthy@intel.com, davem@davemloft.net, realmz6@gmail.com, x86@kernel.org, luto@amacapital.net, keescook@chromium.org, torvalds@linux-foundation.org, gregkh@linuxfoundation.org, rusty@rustcorp.com.au, gnomes@lxorguk.ukuu.org.uk, alan@linux.intel.com, dwmw2@infradead.org, arnd@arndb.de, ming.lei@canonical.com, linux-arch@vger.kernel.org, benh@kernel.crashing.org, ananth@in.ibm.com, pebolle@tiscali.nl, fontana@sharpeleven.org, david.vrabel@citrix.com, konrad.wilk@oracle.com, mcb30@ipxe.org, jgross@suse.com, andrew.cooper3@citrix

On Thu, 25 Aug 2016 08:05:40 +0200
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> On Thu, Aug 25, 2016 at 12:06:33PM +1000, Nicholas Piggin wrote:
> > On Wed, 24 Aug 2016 22:12:53 +0200
> > "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:  
> > > But:
> > > 
> > > git grep SECTION_TEXT works as expected immediately.
> > > 
> > > I guess its a matter of perspective.
> > >   
> > > > They are also
> > > > the names you'll be grepping for when you look at disassembly.    
> > > 
> > > Sure but if you're grepping asm, you very likely know what to look for.  
> > 
> > After you have gone through the extra layer of naming indirection
> > to work out what it is. I'm still not sold on the name indirection
> > and hiding wildcards. Not just for asm grepping, but I don't think
> > it's a negative thing for devs working on the linker to know what
> > actual section names and commands are being used, as much as possible.  
> 
> OK lets see what it looks like after dropping them. Will try that.
> 
> > > The idea was to add helpers to do the globbing more easily.
> > > 
> > > The glob for sections now documented   is SECTION_ALL()
> > > The glob that is range specific        is SECTION_RNG_ALL()
> > > The glob that is linker table specific is SECTION_TBL_ALL()  
> > 
> > I still don't see this is better than
> > 
> > .text*
> > .text.*
> > .text.range.*
> > .text.table.*
> > etc.  
> 
> OK will drop it.

Thank you for considering it, I appreciate that.


> > > How about:
> > > 
> > > At the top just use "Linux sections helpers"
> > > 
> > > Then:
> > > 
> > > /**
> > >  * DOC: Introduction
> > >  *
> > >  * We document below a dedicated set of helpers used in Linux to make sections
> > >  * defined in the Linux linker script accessible in C code in a generic form and 
> > >  * and provide certain attributes about them.
> > >  */
> > >   
> > > > I just can't work out what exactly is a
> > > > "custom Linux section", and what DECLARE_LINUX_SECTION(), for example, actaully
> > > > gives you.    
> > > 
> > > Its a way to replace the:
> > > 
> > > extern char foo[], foo__end[];
> > > 
> > > So this provides a generalized form to use declarations used in C code to make
> > > the linker script start and end symbols from esctions accessible in C code. Since
> > > DEFINE_SECTION_RANGE() and DEFINE_LINKTABLE() macros use this, then the
> > > DECLARE_LINUX_SECTION() is only needed if you need access to these symbols in C
> > > code outside of the one that is defining and mainly in charge of managing the
> > > section. We provide DECLARE_*() helpers for section ranges and linker tables
> > > though so those can be used instead to help annotate the type of a custom
> > > section they are.  
> > 
> > Oh, that makes more sense. The SECTION stuff and custom sections was
> > confusing me. I would prefer just to drop all the LINUX_SECTION naming
> > and make it match the functionality you're using. For example:
> > 
> > +DEFINE_LINKTABLE(struct jump_entry, __jump_table);
> > +
> >  /* mutex to protect coming/going of the the jump_label table */
> >  static DEFINE_MUTEX(jump_label_mutex);
> >  
> > @@ -274,8 +277,6 @@ static void __jump_label_update(struct static_key *key,
> >  
> >  void __init jump_label_init(void)
> >  {
> > -	struct jump_entry *iter_start = __start___jump_table;
> > -	struct jump_entry *iter_stop = __stop___jump_table;
> >  	struct static_key *key = NULL;
> >  	struct jump_entry *iter;
> >  
> > @@ -292,9 +293,10 @@ void __init jump_label_init(void)
> >  		return;
> >  
> >  	jump_label_lock();
> > -	jump_label_sort_entries(iter_start, iter_stop);
> > +	jump_label_sort_entries(LINUX_SECTION_START(__jump_table),
> > +				LINUX_SECTION_END(__jump_table));
> > 
> > Now I think this is a fine abstraction to have.  
> 
> OK will keep this one.
> 
> > I think it would look
> > even cleaner if you had:
> > 
> > LINKTABLE_START(__jump_table)
> > LINKTABLE_END(__jump_table)
> >
> > Then do we need to even have the LINUX_SECTION middle man at all?  
> 
> Ah, thing is we use this for both linktables and section ranges.
> Or do we want macros for both that do the same thing ?

I think it would make the code using it more readable.

Thanks,
Nick
