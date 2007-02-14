From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 14 Feb 2007 18:37:43 +0000
Subject: Re: 2.6.20 new perfmon code base + libpfm + pfmon
Message-Id: <20070214103743.3cb1c39c.akpm@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070213184839.GC10031@frankl.hpl.hp.com>
	<20070213140533.a5ca27ad.akpm@linux-foundation.org>
	<20070214182932.GG11681@frankl.hpl.hp.com>
In-Reply-To: <20070214182932.GG11681@frankl.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: eranian@hpl.hp.com
Cc: perfmon@napali.hpl.hp.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net, perfctr-devel@lists.sourceforge.net

On Wed, 14 Feb 2007 10:29:32 -0800
Stephane Eranian <eranian@hpl.hp.com> wrote:

> On Tue, Feb 13, 2007 at 02:05:33PM -0800, Andrew Morton wrote:
> > > On Tue, 13 Feb 2007 10:48:39 -0800 Stephane Eranian <eranian@hpl.hp.com> wrote:
> > > I have released another version of the perfmon new code base package.
> > 
> > Can we have a bug push to get this merged up please?
> 
> Could you please indicate the procedure to do this?

re-post the patches for review-and-possible-integration, as you did last
time, I guess.

> Do you "just" need a patch against your latest -mm tree?

You should only raise patches against -mm is there's a special need to do
that (usually: they're against something which is only in -mm).  Patches
against 2.6.21-rc1 should suit.

