From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 15 Jun 2006 21:39:16 +0000
Subject: RE: Why does ia64 not use fetchadd in atomic.h?
Message-Id: <000201c690c4$286d2870$e434030a@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606151323380.10549@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606151323380.10549@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, June 15, 2006 2:29 PM
> > On Thu, Jun 15, 2006 at 01:35:42PM -0700, Christoph Lameter wrote:
> > > Why not
> > > 
> > > #define ia64_atomic_add(__i, __v) ia64_fetchadd(__i, &v->counter, acq)
> > 
> > Because ia64_fetchadd() only supports 8 different constants?
> 
> Right. I forgot about that. Only a call to atomic_add does the fetchadd 
> trickery. Thanks.


I guess I got confused, are you complaining about ia64_atomic_add or
ia64_atomic64_add?  If the former, there is not much can be done, but if
the latter, yeah, it can be optimized for certain constant.

