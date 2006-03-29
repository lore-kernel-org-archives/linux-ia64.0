From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 01:39:37 +0000
Subject: RE: Fix unlock_buffer() to work the same way as bit_unlock()
Message-Id: <200603290139.k2T1d1g00702@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0603281644270.16702@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603271953150.7469@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@sgi.com>
Cc: 'Nick Piggin' <nickpiggin@yahoo.com.au>, Zoltan Menyhart <Zoltan.Menyhart@free.fr>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Christoph Lameter wrote on Tuesday, March 28, 2006 4:47 PM
> > Why not make unlock_buffer use test_and_clear_bit()?  Utilizing it's implied
> > full memory fence and throw away the return value?  OK, OK, this is obscured.
> > Then introduce clear_bit_memory_fence API or some sort.
> 
> Only for IA64's sake? Better clean up the bitops as you suggested earlier. 
> The open ended acquires there leaves a weird feeling.
> 
> Something like this? (builds fine not tested yet)

It's warm and fuzzy feeling with changes in set_bit(), clear_bit(), and
change_bit().  The API never meant to have implied memory fence in them.
Though the usage might be assuming one way or the other because of x86
semantics.

How many of these things are used as (1) simple atomic op, (2) lock,
(3) unlock, and (4) full fence?

clear_bit  - 1,070 hits
Set_bit    - 1,450 hits
Change_bit -     8 hits

The effect of changing them to full memory fence could be wide spread. Though
I don't have any numbers yet to say how much it will matter for performance.

- Ken
