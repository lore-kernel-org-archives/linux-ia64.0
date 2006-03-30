From: "Boehm, Hans" <hans.boehm@hp.com>
Date: Thu, 30 Mar 2006 22:17:28 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <65953E8166311641A685BDF71D865826A23E90@cacexc12.americas.cpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Trimmed linux-kernel, since this is IA64 specific.]
> From: Christoph Lameter 
> The question is what does fence imply for the order of the 
> atomic operation. Will the operation be performed before or 
> after the barrier? 
> Or do we need barriers on both sides?
I would assume so.

> 
> If so then we may simulate that with a release and then do a 
> acquire load afterwards
> 
> 	 cmpxchg_rel(m, old, new);
> 	 return *m;	/* m volatile so it has acquire semantics */

Is this really what you intended?

The cmpxchg and the read of *m are not atomic.  Operations in other
threads may intervene.

After looking at the spec again, I am convinced that it enforces
ordering.  But I'm not sure that helps.  I would guess that just adding
an mf at the end will give you at least similar performance.

Hans

