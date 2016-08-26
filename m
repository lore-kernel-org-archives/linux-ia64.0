From: Nicholas Piggin <npiggin@gmail.com>
Date: Fri, 26 Aug 2016 07:33:38 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160826173338.41a56103@roar.ozlabs.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471642454-5679-1-git-send-email-mcgrof@kernel.org>
        <1471642454-5679-5-git-send-email-mcgrof@kernel.org>
        <20160823112633.7d482e62@roar.ozlabs.ibm.com>
        <20160823173306.GA3296@wotan.suse.de>
        <20160824135141.2c8f06ec@roar.ozlabs.ibm.com>
        <20160824201253.GS3296@wotan.suse.de>
        <20160825120633.057b2f6f@roar.ozlabs.ibm.com>
        <20160825060540.GX3296@wotan.suse.de>
        <20160825165121.45d26fb0@roar.ozlabs.ibm.com>
        <20160825175239.GB3296@wotan.suse.de>
        <20160826130024.0ad51d33@roar.ozlabs.ibm.com>
        <CAB=NE6UQ8qE6AqRg9=YddNYrMyU7opCEij-5Usty7wMgEJJbpw@mail.gmail.com>
In-Reply-To: <CAB=NE6UQ8qE6AqRg9=YddNYrMyU7opCEij-5Usty7wMgEJJbpw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: benh@kernel.crashing.org, jani.nikula@intel.com, masami.hiramatsu.pt@hitachi.com, linux@rasmusvillemoes.dk, linux-kbuild@vger.kernel.org, linux-sh@vger.kernel.org, luto@amacapital.net, gnomes@lxorguk.ukuu.org.uk, jcmvbkbc@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, dwmw2@infradead.org, xen-devel@lists.xensource.com, anil.s.keshavamurthy@intel.com, will.deacon@arm.com, linux-ia64@vger.kernel.org, x86@kernel.org, korea.drzix@gmail.com, mingo@redhat.com, andrew.cooper3@citrix.com, jgross@suse.com, tglx@linutronix.de, keescook@chromium.org, ananth@linux.vnet.ibm.com, jpoimboe@redhat.com, rostedt@goodmis.org, hpa@zytor.com, acme@redhat.com, arnd@arndb.de, davem@davemloft.net, platform-driver-x86@vger.kernel.org, jkosina@suse.cz, david.vrabel@citrix.com

On Thu, 25 Aug 2016 23:38:44 -0700
"Luis R. Rodriguez" <mcgrof@kernel.org> wrote:

> On Aug 25, 2016 8:00 PM, "Nicholas Piggin" <npiggin@gmail.com> wrote:
> >
> > On Thu, 25 Aug 2016 19:52:39 +0200
> > "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
> >  
> > > On Thu, Aug 25, 2016 at 04:51:21PM +1000, Nicholas Piggin wrote:  
> > > > On Thu, 25 Aug 2016 08:05:40 +0200
> > > > "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:  
> > > > > > Oh, that makes more sense. The SECTION stuff and custom sections  
> was
> > > > > > confusing me. I would prefer just to drop all the LINUX_SECTION  
> naming
> > > > > > and make it match the functionality you're using. For example:
> > > > > >
> > > > > > +DEFINE_LINKTABLE(struct jump_entry, __jump_table);
> > > > > > +
> > > > > >  /* mutex to protect coming/going of the the jump_label table */
> > > > > >  static DEFINE_MUTEX(jump_label_mutex);
> > > > > >
> > > > > > @@ -274,8 +277,6 @@ static void __jump_label_update(struct  
> static_key *key,
> > > > > >
> > > > > >  void __init jump_label_init(void)
> > > > > >  {
> > > > > > -       struct jump_entry *iter_start = __start___jump_table;
> > > > > > -       struct jump_entry *iter_stop = __stop___jump_table;
> > > > > >         struct static_key *key = NULL;
> > > > > >         struct jump_entry *iter;
> > > > > >
> > > > > > @@ -292,9 +293,10 @@ void __init jump_label_init(void)
> > > > > >                 return;
> > > > > >
> > > > > >         jump_label_lock();
> > > > > > -       jump_label_sort_entries(iter_start, iter_stop);
> > > > > > +       jump_label_sort_entries(LINUX_SECTION_START(__jump_table),
> > > > > > +                               LINUX_SECTION_END(__jump_table));
> > > > > >
> > > > > > Now I think this is a fine abstraction to have.  
> > > > >
> > > > > OK will keep this one.
> > > > >  
> > > > > > I think it would look
> > > > > > even cleaner if you had:
> > > > > >
> > > > > > LINKTABLE_START(__jump_table)
> > > > > > LINKTABLE_END(__jump_table)
> > > > > >
> > > > > > Then do we need to even have the LINUX_SECTION middle man at all?  
> > > > >
> > > > > Ah, thing is we use this for both linktables and section ranges.
> > > > > Or do we want macros for both that do the same thing ?  
> > > >
> > > > I think it would make the code using it more readable.  
> > >
> > > Alrighty... so:
> > >
> > > LINKTABLE_START()
> > > LINKTABLE_END()
> > >
> > > SECTION_RANGE_START()
> > > SECTION_RANGE_END()
> > >
> > > And these macros do the exact same thing. Ie, nothing shared. Right?  
> >
> > Yeah I think so. Internally they would probably be aliased to the
> > same common definition (unless you had some type check or something),
> > but user would know about such details.  
> 
> What name should we use for such common macro definition ?


Ah, not really sure. I guess the "link table" is some kind of
section range? I haven't actually looked closely at both of them
in the subsequent patches. It matters less if it's not expected
to be used as an API though.
