From: Martin Pool <mbp@sourcefrog.net>
Date: Wed, 29 Oct 2003 06:22:42 +0000
Subject: Re: show_mem panics in 2.4.22
Message-Id: <marc-linux-ia64-106740860819780@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106731898417513@msgid-missing>
In-Reply-To: <marc-linux-ia64-106731898417513@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 29 Oct 2003, Martin Pool <mbp@sourcefrog.net> wrote:
> On 28 Oct 2003, John Marvin <jsm@udlkern.fc.hp.com> wrote:
> > > I'm running linux-2.4.22-ia64-030909 on an rx2600.  The show_mem()
> > > function always causes a kernel panic.  This is reached when you send
> > > 'SysRq m' or serial 'BREAK m' to find out about used memory, etc.
> > >
> > > The problem seems to be that this function is written assuming that
> > > the discontiguous memory scheme is used, but that's not the case in my
> > > configuration.  I see that in 2.6.0-test8 there are two versions of
> > > the function for the contig/discontig cases.  The crash is on the line
> > > that reads through pgdat->node_mem_map.  I'm not sure exactly what is
> > > wrong with that.
> > 
> > 
> > I'm not sure why this just started to show up. The problem is that
> > the size of struct page doesn't divide into the page size evenly, so
> > the structure overlaps holes in the mem_map array. Here is a fix,
> > but I am still not sure of the performance implications (extra memory
> > dereference). There may be a better fix, although not as simple, if
> > this has performance implications.

I made a mistake in merging your patch.  That does fix it for me.

Does the mem_map have unmapped pages in it because
free_area_init_core() pokes holes in it for pages that are not
physically present?

-- 
Martin 
