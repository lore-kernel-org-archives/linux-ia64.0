From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Thu, 04 Sep 2014 08:57:40 +0000
Subject: Re: bit fields && data tearing
Message-Id: <21512.10628.412205.873477@gargle.gargle.HOWL>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>
	<54079B70.4050200@hurleysoftware.com>
	<1409785893.30640.118.camel@pasglop>
In-Reply-To: <1409785893.30640.118.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Peter Hurley <peter@hurleysoftware.com>, Jakub Jelinek <jakub@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Richard Henderson <rth@twiddle.net>, Oleg Nesterov <oleg@redhat.com>, Miroslav Franc <mfranc@redhat.com>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Benjamin Herrenschmidt writes:
 > On Wed, 2014-09-03 at 18:51 -0400, Peter Hurley wrote:
 > 
 > > Apologies for hijacking this thread but I need to extend this discussion
 > > somewhat regarding what a compiler might do with adjacent fields in a structure.
 > > 
 > > The tty subsystem defines a large aggregate structure, struct tty_struct.
 > > Importantly, several different locks apply to different fields within that
 > > structure; ie., a specific spinlock will be claimed before updating or accessing
 > > certain fields while a different spinlock will be claimed before updating or
 > > accessing certain _adjacent_ fields.
 > > 
 > > What is necessary and sufficient to prevent accidental false-sharing?
 > > The patch below was flagged as insufficient on ia64, and possibly ARM.
 > 
 > We expect native aligned scalar types to be accessed atomically (the
 > read/modify/write of a larger quantity that gcc does on some bitfield
 > cases has been flagged as a gcc bug, but shouldn't happen on normal
 > scalar types).
 > 
 > I am not 100% certain of "bool" here, I assume it's treated as a normal
 > scalar and thus atomic but if unsure, you can always use int.

Please use an aligned int or long.  Some machines cannot do atomic
accesses on sub-int/long quantities, so 'bool' may cause unexpected
rmw cycles on adjacent fields.

/Mikael

 > 
 > Another option is to use the atomic bitops and make these bits in a
 > bitmask but that is probably unnecessary if you have locks already.
 > 
 > Cheers,
 > Ben.
 > 
 > 
 > > Regards,
 > > Peter Hurley
 > > 
 > > --- >% ---
 > > Subject: [PATCH 21/26] tty: Convert tty_struct bitfield to bools
 > > 
 > > The stopped, hw_stopped, flow_stopped and packet bits are smp-unsafe
 > > and interrupt-unsafe. For example,
 > > 
 > > CPU 0                         | CPU 1
 > >                               |
 > > tty->flow_stopped = 1         | tty->hw_stopped = 0
 > > 
 > > One of these updates will be corrupted, as the bitwise operation
 > > on the bitfield is non-atomic.
 > > 
 > > Ensure each flag has a separate memory location, so concurrent
 > > updates do not corrupt orthogonal states.
 > > 
 > > Signed-off-by: Peter Hurley <peter@hurleysoftware.com>
 > > ---
 > >  include/linux/tty.h | 5 ++++-
 > >  1 file changed, 4 insertions(+), 1 deletion(-)
 > > 
 > > diff --git a/include/linux/tty.h b/include/linux/tty.h
 > > index 1c3316a..7cf61cb 100644
 > > --- a/include/linux/tty.h
 > > +++ b/include/linux/tty.h
 > > @@ -261,7 +261,10 @@ struct tty_struct {
 > >  	unsigned long flags;
 > >  	int count;
 > >  	struct winsize winsize;		/* winsize_mutex */
 > > -	unsigned char stopped:1, hw_stopped:1, flow_stopped:1, packet:1;
 > > +	bool stopped;
 > > +	bool hw_stopped;
 > > +	bool flow_stopped;
 > > +	bool packet;
 > >  	unsigned char ctrl_status;	/* ctrl_lock */
 > >  	unsigned int receive_room;	/* Bytes free for queue */
 > >  	int flow_change;
 > 
 > 
 > --
 > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
 > Please read the FAQ at  http://www.tux.org/lkml/

-- 
