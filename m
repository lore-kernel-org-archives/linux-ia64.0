From: Mario Smarduch <cms063@email.mot.com>
Date: Wed, 28 Apr 2004 15:52:58 +0000
Subject: Re: cacheble to uncachble change
Message-Id: <408FD35A.FCAEFEDA@email.mot.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <408D5C58.E07A5FBE@email.mot.com>
In-Reply-To: <408D5C58.E07A5FBE@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt wrote:

> On Tue, Apr 27, 2004 at 03:45:48PM -0700, David Mosberger wrote:
> >
> > Yes, but that's the _easy_ part, so to speak.
> >
> > To be honest, I would appreciate if you could outline your strategy to
> > avoid memory-attribute aliasing.  If only because it would give me a
> > warm-and-fuzzy feeling... ;-)
> >
> > If this isn't something you're comfortable discussing on a public
> > list, a private mail would still be appreciated.
>
> I think this is important enough to SGI that we would like to be
> included in this discussion.  One of our employees started working
> on adapting what is currently the needing to be renamed fetchop
> driver to take a whole granule when there are no remaining pages
> in the uncached drivers space, doing the flushes, sync.i, srlz.i
> sequences to ensure all cache lines are flushed and then shoot down
> the existing TLB entries before adding the pages of the granule to
> the uncached drivers space.  This sounds similar to what is being
> proposed here, I believe.
>
> Thanks,
> Robin

The situation I'm working with requires atleast 8MB of contiguous
memory to maintain a dirty bit map. Sometimes only the first 4k
of that bitmap may be updated/read&cleared and other times all
8MB. On 8-way and beyond systems access to dirty bitmap may degrade
performance due to coherency if the width of the locality is small,
then  I think it makes sense to change to uncached. On the other hand if
 some threshold is crossed where spatial locality width compensates
for coherency overhead then the block should be switched to
cached attribute. At this point the threshold is unknown. I was
under the impression that I could via alloc_bootmem() grab a
contiguous peiece of memory which can be accessed via
reg6 & reg7. When switching from uncachable to cachable
all activity to the dirty bit map would be halted (via locks in
cacheble memory, application controlled) and the procedure
David pointed to in the Sys Arch document can be applied (except
physical PTE part) the locks released and accesses would be
done via reg6. But now that I look at it, it seems that TRs  pin the
kernel as well with cacheble attribute.

- Mario.

