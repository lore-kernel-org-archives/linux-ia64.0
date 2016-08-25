From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Date: Thu, 25 Aug 2016 17:52:39 +0000
Subject: Re: [PATCH v4 04/16] generic-sections: add section core helpers
Message-Id: <20160825175239.GB3296@wotan.suse.de>
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
In-Reply-To: <20160825165121.45d26fb0@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicholas Piggin <npiggin@gmail.com>
Cc: gnomes@lxorguk.ukuu.org.uk, linux-ia64@vger.kernel.org, jkosina@suse.cz, benh@kernel.crashing.org, ming.lei@canonical.com, heiko.carstens@de.ibm.com, platform-driver-x86@vger.kernel.org, James.Bottomley@HansenPartnership.com, paul.gortmaker@windriver.com, paulus@samba.org, mpe@ellerman.id.au, hpa@zytor.com, masami.hiramatsu.pt@hitachi.com, mchehab@osg.samsung.com, linux-arch@vger.kernel.org, markus.heiser@darmarit.de, sparclinux@vger.kernel.org, xen-devel@lists.xensource.com, linux@arm.linux.org.uk, linux-sh@vger.kernel.org, will.deacon@arm.com, korea.drzix@gmail.com, x86@kernel.org, anil.s.keshavamurthy@intel.com, fontana@sharpeleven.org, mingo@redhat.com, linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, dvhart@infradead.org, dwmw2@infradead.org, david.vrabel@citrix.com, linux-xtensa@linux-xtensa.org, pali.rohar@gmail.com, keescook@chromium.org, arnd@arndb

On Thu, Aug 25, 2016 at 04:51:21PM +1000, Nicholas Piggin wrote:
> On Thu, 25 Aug 2016 08:05:40 +0200
> "Luis R. Rodriguez" <mcgrof@kernel.org> wrote:
> > > Oh, that makes more sense. The SECTION stuff and custom sections was
> > > confusing me. I would prefer just to drop all the LINUX_SECTION naming
> > > and make it match the functionality you're using. For example:
> > > 
> > > +DEFINE_LINKTABLE(struct jump_entry, __jump_table);
> > > +
> > >  /* mutex to protect coming/going of the the jump_label table */
> > >  static DEFINE_MUTEX(jump_label_mutex);
> > >  
> > > @@ -274,8 +277,6 @@ static void __jump_label_update(struct static_key *key,
> > >  
> > >  void __init jump_label_init(void)
> > >  {
> > > -	struct jump_entry *iter_start = __start___jump_table;
> > > -	struct jump_entry *iter_stop = __stop___jump_table;
> > >  	struct static_key *key = NULL;
> > >  	struct jump_entry *iter;
> > >  
> > > @@ -292,9 +293,10 @@ void __init jump_label_init(void)
> > >  		return;
> > >  
> > >  	jump_label_lock();
> > > -	jump_label_sort_entries(iter_start, iter_stop);
> > > +	jump_label_sort_entries(LINUX_SECTION_START(__jump_table),
> > > +				LINUX_SECTION_END(__jump_table));
> > > 
> > > Now I think this is a fine abstraction to have.  
> > 
> > OK will keep this one.
> > 
> > > I think it would look
> > > even cleaner if you had:
> > > 
> > > LINKTABLE_START(__jump_table)
> > > LINKTABLE_END(__jump_table)
> > >
> > > Then do we need to even have the LINUX_SECTION middle man at all?  
> > 
> > Ah, thing is we use this for both linktables and section ranges.
> > Or do we want macros for both that do the same thing ?
> 
> I think it would make the code using it more readable.

Alrighty... so:

LINKTABLE_START()
LINKTABLE_END()

SECTION_RANGE_START()
SECTION_RANGE_END()

And these macros do the exact same thing. Ie, nothing shared. Right?

  Luis
