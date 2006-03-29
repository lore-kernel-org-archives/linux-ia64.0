From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 29 Mar 2006 07:11:06 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <Pine.LNX.4.64.0603282308490.20328@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200603290645.k2T6jbg03728@unix-os.sc.intel.com>
In-Reply-To: <200603290645.k2T6jbg03728@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tue, 28 Mar 2006, Chen, Kenneth W wrote:

> Nick Piggin wrote on Tuesday, March 28, 2006 6:36 PM
> > Hmm, not sure. Maybe a few new bitops with _lock / _unlock postfixes?
> > For page lock and buffer lock we'd just need test_and_set_bit_lock,
> > clear_bit_unlock, smp_mb__after_clear_bit_unlock.
> > 
> > I don't know, _for_lock might be a better name. But it's getting long.
> 
> I think kernel needs all 4 variants:
> 
> clear_bit
> clear_bit_lock
> clear_bit_unlock
> clear_bit_fence
> 
> And the variant need to permutated on all other bit ops ...  I think it
> would be indeed a better API and be more explicit about the ordering.

How about clear_bit(why, bit, address) in order to keep 
the variants down? Get rid of the smp_mb__*_xxxx stuff.




