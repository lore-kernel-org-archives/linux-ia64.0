From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 29 Apr 2005 00:21:35 +0000
Subject: RE: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504281720270.25133@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 28 Apr 2005, Chen, Kenneth W wrote:

> Christoph Lameter wrote on Thursday, April 28, 2005 3:52 PM
> > +static inline void _raw_write_unlock(rwlock_t *x) {
> > +	u8 *y = (u8 *)x;
> > +	barrier();
> > +	asm volatile ("st1.rel.nta [%0] = r0\n\t" :: "r"(y+3) : "memory" ); }
>
> Perhaps you should make this code icc friendly by not using asm directly.
> Intel compiler doesn't support asm statement.

How do I do a store with release and nontemporal semantics without asm?
