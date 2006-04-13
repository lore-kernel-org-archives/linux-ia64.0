From: "Bob Picco" <bob.picco@hp.com>
Date: Thu, 13 Apr 2006 16:15:10 +0000
Subject: Re: show_mem() for ia64 discontig takes a really long time on large systems.
Message-Id: <20060413161510.GI23742@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
In-Reply-To: <20060328184315.GA8162@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:	[Thu Apr 13 2006, 12:02:52PM EDT]
> On Wed, Apr 12, 2006 at 01:36:40PM -0400, Bob Picco wrote:
> > Looks great and will work for VIRTUAL_MEM_MAP.  It's too bad SPARSEMEM
> > can't be used because this probably wouldn't be an issue.  
> > 
> > I think this will break SPARSEMEM. Perhaps it's time to create a new
> > module with VIRTUAL_MEM_MAP specific code in it. Say like vmemmap.c.
> > Lots of code in init.c and this new code could reside in this new
> > module. Just a thought.  You'll need a compile time optimized out feature for 
> > SPARSEMEM but for VIRTUAL_MEM_MAP a function call could be called.
> 
> Bob,
> 
> I forgot to address this concern.  I do nothing with SPARSEMEM and am
> not really sure where to dive in.  What ia64 boxes use SPARSEMEM?
> If I simply skip the doing anything to i in the SPARSEMEM case, would
> that be sufficient?  Essentially:
> 
>                        else {
> #ifdef CONFIG_SPARSEMEM
>                                 i = find_next_valid_pfn_for_pgdat(pgdat, i) - 1;
> #endif
>                                 continue;
>                         }
> 
> Only done with the function definition above.
> 
> Thanks,
> Robin
Robin,

Sorry just saw this. We had a 16 hour imap server outage.  I posted to your 
patch about this issue.

bob
