From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 01:40:22 +0000
Subject: Re: Synchronizing Bit operations V2
Message-Id: <Pine.LNX.4.64.0603301738190.2758@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060331013346.913.qmail@science.horizon.com>
In-Reply-To: <20060331013346.913.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux@horizon.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 30 Mar 2006, linux@horizon.com wrote:

> The only conceivable reason for passing the mode as a separate parameter is
> - To change the mode dynamically at run time.
> - To share common code when the sequence is long and mostly shared
>   between the various modes (as in open(2) or ll_rw_block()).

There is usually quite complex code involved although the code generated 
is minimal.

> On the downside, it's more typing and uglier than a series of
> 
> frob_bit_nonatomic()
> 	(probably temporarily or permanently aliased to frob_bit())
> frob_bit_atomic()
> frob_bit_acquire()
> frob_bit_release()
> frob_bit_barrier()
> 
> functions, and those also prevent you from doing something silly like
> frob_bit(x, y, O_DIRECT).  Also, the MODE_ prefix might be wanted by
> something else.

Ok. We could change the MODE_ prefix but the problem with not passing this 
as a parameter that there are numerous functions derived from bit ops that 
are then also needed in lots of different flavors. Passing a parameter 
cuts down the number of variations dramatically.

