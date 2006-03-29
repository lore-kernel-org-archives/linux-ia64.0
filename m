From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 00:12:42 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <200603290012.k2T0C6g32166@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603281537500.15037@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>, 'Nick Piggin' <nickpiggin@yahoo.com.au>
Cc: Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, March 28, 2006 3:48 PM
> On Tue, 28 Mar 2006, Zoltan Menyhart wrote:
> 
> > Why not to use separate bit operations for different purposes?
> > 
> > - e.g. "test_and_set_bit_N_acquire()" for lock acquisition
> > - "test_and_set_bit()", "clear_bit()" as they are today
> > - "release_N_clear_bit()"...
> > 
> 
> That would force IA64 specifics onto all other architectures.
> 
> Could we simply define these smb_mb__*_clear_bit to be noops
> and then make the atomic bit ops to have full barriers? That would satisfy 
> Nick's objections.
> 
> --- linux-2.6.16.orig/include/asm-ia64/bitops.h	2006-03-19 21:53:29.000000000 -0800
> +++ linux-2.6.16/include/asm-ia64/bitops.h	2006-03-28 15:45:08.000000000 -0800
> @@ -45,6 +45,7 @@
>  		old = *m;
>  		new = old | bit;
>  	} while (cmpxchg_acq(m, old, new) != old);
> +	smb_mb();
>  }

There are better way to do it.  The pointer is already cast as volatile,
so old = *m has acq semantics built-in, we can just change cmpxchg_acq to
cmpxchg_rel, then effectively it is a full memory barrier without doing the
expensive smp_mb().

- Ken
