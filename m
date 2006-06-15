From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 15 Jun 2006 21:28:35 +0000
Subject: Re: Why does ia64 not use fetchadd in atomic.h?
Message-Id: <Pine.LNX.4.64.0606151428080.10780@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0606151323380.10549@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0606151323380.10549@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 15 Jun 2006, Matthew Wilcox wrote:

> On Thu, Jun 15, 2006 at 01:35:42PM -0700, Christoph Lameter wrote:
> > Why not
> > 
> > #define ia64_atomic_add(__i, __v) ia64_fetchadd(__i, &v->counter, acq)
> 
> Because ia64_fetchadd() only supports 8 different constants?

Right. I forgot about that. Only a call to atomic_add does the fetchadd 
trickery. Thanks.


