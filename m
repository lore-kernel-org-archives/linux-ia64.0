From: Hans Boehm <Hans.Boehm@hp.com>
Date: Fri, 08 Jun 2007 05:59:01 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.GHP.4.58.0706072241410.4538@tomil.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Thu, 7 Jun 2007, Christoph Lameter wrote:

> On Fri, 8 Jun 2007, Boehm, Hans wrote:
>
> > This of course causes problems for applications that try to use page
> > protection to track updates or are relying on small granularity
> > copy-on-write, or the like.  Anything that uses our garbage collector in
> > incremental mode will fit that description, though I don't believe there
> > are currently many such applications.  Checkpointing may be another
>
> Why is that a problem? The granularity would change right?
The granularity would change.  If you are using faults to track possibly
written data (e.g. for checkpoints or GC), and a small number of writes
are distributed randomly through the address space (admittedly worst
case) then 4 times as many bytes appear to be potentially written,
and hence you may have to copy or scan 4 times as many bytes.
I think the potential down side in cases like this is substantial,
though it's probably quite rare.  Fpr software DSM it's probably even
worse, since you are likely to introduce more false sharing.
>
> > similar issue, at least for some applications.  Software DSM
> > implementations would clearly be affected.  I would guess that the trend
> > is likely to be towards more of this in all three of those areas.
>
> Which?
Checkpoints may become more important, since I hear that predictions are
for increased hardware rates as feature sizes shrink.  We are seriously
considering putting GC in the C++ standard, which would probably move
incremental GC based on VM write barriers much closer to the mainstream.
It seems to me that software DSM is probably becoming more
competitive as the time it takes to transfer a page decreases.
>
> > I am not really arguing against this, since I don't have a good overview
> > of how many customers are likely to be affected.  I just want to make
> > sure that both sides of the issue are considered.
>
> SLES9 is available in a 64k page size version. Some customers still run
> that one because it is faster.
>
That doesn't surprise me.  That's why I'm not arguing that this is clearly
a bad idea.
>

Hans
