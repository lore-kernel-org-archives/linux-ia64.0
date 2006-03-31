From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 21:15:50 +0000
Subject: RE: Fix ia64 bitops: Full barrier on smp_mb__after_clear_bit()
Message-Id: <Pine.LNX.4.64.0603311315300.8003@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603311124380.7426@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603311124380.7426@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 31 Mar 2006, Chen, Kenneth W wrote:

> > /*
> >  * clear_bit doesn't imply a memory barrier
> >  */
> > #define smp_mb__before_clear_bit()      smp_mb()
> > #define smp_mb__after_clear_bit()       smp_mb()
> 
> 
> Using a totally different architecture to justify a change for ia64
> specific implementation is a bit strange to me.  PPC has their own
> architecture limitation to deal with, why mix that with ia64?

Because clear_bit() on IA64 does not imply a memory barrier either.

