From: linux@horizon.com
Date: Fri, 31 Mar 2006 01:33:46 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <20060331013346.913.qmail@science.horizon.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603301615540.2023@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: clameter@sgi.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> The following patchset implements the ability to specify a
> synchronization mode for bit operations.
>
> I.e. instead of set_bit(x,y) we can do set_bit(x,y, mode).
> 
> The following modes are supported:

Yuck.

The only conceivable reason for passing the mode as a separate parameter is
- To change the mode dynamically at run time.
- To share common code when the sequence is long and mostly shared
  between the various modes (as in open(2) or ll_rw_block()).

I sincerely hope neither of those apply in this case.

On the downside, it's more typing and uglier than a series of

frob_bit_nonatomic()
	(probably temporarily or permanently aliased to frob_bit())
frob_bit_atomic()
frob_bit_acquire()
frob_bit_release()
frob_bit_barrier()

functions, and those also prevent you from doing something silly like
frob_bit(x, y, O_DIRECT).  Also, the MODE_ prefix might be wanted by
something else.
