From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 23 Sep 2005 00:58:04 +0000
Subject: Re: [PATCH] Increase maximum kmalloc size to 256K
Message-Id: <20050923005804.GI26389@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0509221306380.18133@schroedinger.engr.sgi.com> <20050922131521.77da1684.akpm@osdl.org> <Pine.LNX.4.62.0509221329270.18240@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0509221329270.18240@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, manfred@colorfulllife.com

On Thu, Sep 22, 2005 at 01:55:43PM -0700, Christoph Lameter wrote:
> On Thu, 22 Sep 2005, Andrew Morton wrote:
> 
> > Christoph Lameter <clameter@engr.sgi.com> wrote:
> > >
> > >  The workqueue structure can grow larger than 128k under 2.6.14-rc2 (with 
> > >  all debugging features enabled on 64 bit platforms)
> > 
> > Would it be better to use alloc_percpu() in there?  Bearing in mind that
> > one day we'll probably have an alloc_percpu() which incurs one less
> > indirection and which allocates things node-affinely.
> 
> Yes I am working on a patch like that right now. But there is still the 
> danger that other structures also may get big in the future. It would 
> be best to raise the limit.

It would be better to leave the limit alone so other structures which
get ridiculously big are also caught and fixed.
