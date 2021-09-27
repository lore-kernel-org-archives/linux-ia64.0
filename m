From: Petr Mladek <pmladek@suse.com>
Date: Mon, 27 Sep 2021 11:15:42 +0000
Subject: Re: [PATCH v2] ia64: don't do IA64_CMPXCHG_DEBUG without CONFIG_PRINTK
Message-Id: <YVGn3ptoeDsXs58J@alley>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210926171224.27019-1-rdunlap@infradead.org>
In-Reply-To: <20210926171224.27019-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun 2021-09-26 21:53:33, Randy Dunlap wrote:
> On 9/26/21 8:22 PM, Paul Gortmaker wrote:
> > [[PATCH v2] ia64: don't do IA64_CMPXCHG_DEBUG without CONFIG_PRINTK] On 26/09/2021 (Sun 10:12) Randy Dunlap wrote:
> > 
> > > When CONFIG_PRINTK is not set, the CMPXCHG_BUGCHECK() macro calls
> > > _printk(), but _printk() is a static inline function, not available
> > > as an extern.
> > > Since the purpose of the macro is to print the BUGCHECK info,
> > > make this config option depend on PRINTK.
> > > 
> > > Fixes multiple occurrences of this build error:
> > > 
> > > ../include/linux/printk.h:208:5: error: static declaration of '_printk' follows non-static declaration
> > >    208 | int _printk(const char *s, ...)
> > >        |     ^~~~~~~
> > > In file included from ../arch/ia64/include/asm/cmpxchg.h:5,
> > > ../arch/ia64/include/uapi/asm/cmpxchg.h:146:28: note: previous declaration of '_printk' with type 'int(const char *, ...)'
> > >    146 |                 extern int _printk(const char *fmt, ...);
> > > 
> > > Fixes: 85f8f7759e41 ("ia64: populate the cmpxchg header with appropriate code")
> > 
> > I don't think this fixes tag makes sense either as it was just a
> > straightforward code relocation.  As pointed out elsewhere, it will
> > probably be back even further where CONFIG_PRINTK was introduced, which
> > would be d59745ce3e7a (2005 vintage).  The ia64 debug option predates
> > git, so it isn't at fault (and you can't blame it anyway).
> > 
> > Honestly, realize this is just for a randconfig for ia64 where PRINTK is
> > disabled - something that will never be done in any of the remaining
> > ia64 deployments out there (if there is any).  So I'd just recommend
> > dropping the Fixes tag and move on.  It isn't like there is a lot of
> > people out there doing randconfig builds on linux-stable releases.
> > 
> 
> Yes, I like the idea of dropping the Fixes: tag also. Thanks.
> Guess I'll send a v3.

I could take it via printk tree. I am going to wait 2-3 more days
just in case anyone has a comment.

Feel free to send v3 but I could just remove the tag when pushing v2.

Best Regards,
Petr
