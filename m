From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 27 Sep 2005 00:12:57 +0000
Subject: Re: [Lhms-devel] Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <1127779977.10315.6.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 2005-09-26 at 19:35 -0400, Bob Picco wrote:
> > regular scripts.  Right now this whole change is a close to being
> > a no-op as none of the default configs enables SPARSEMEM.
>
> This is true and just about universally true for other arches with SPARSEMEM
> enabled. I took a quick look and only i386 selects SPARSEMEM for NUMA.
> I couldn't find any default config files with SPARSEMEM.  I think the objective
> was for more soak time before defaulting to SPARSEMEM. Also just a few
> arches have SPARSEMEM support.  Dave Hansen can possibly fill in my gaps.

Usually a change being an effective no-op for those that don't care is a
*plus* for a patch :)

In any case, no, it isn't the default for anything, yet.  This is
partially because sparsemem isn't a universal win over discontig in all
cases.  We wanted to allow a bit of choice.  This phased introduction is
a bit smoother that just wiping out discontigmem completely. 

On i386 it isn't the default because sparsemem is really only good in
places where discontig was used as well.  i386 only uses discontig and
NUMA together.  So, it was natural to keep the same relationship with
sparsemem. 

-- Dave



