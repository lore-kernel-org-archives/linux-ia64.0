From: Dean Nelson <dcn@sgi.com>
Date: Tue, 31 Aug 2004 19:22:41 +0000
Subject: Re: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Message-Id: <20040831192241.GA3601@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163514.GB27891@sgi.com>
In-Reply-To: <20040616163514.GB27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 24, 2004 at 08:17:33PM +0100, Christoph Hellwig wrote:
> On Tue, Aug 24, 2004 at 01:23:44PM -0500, Dean Nelson wrote:
> > Index: linux/arch/ia64/Kconfig
> > =================================> > --- linux.orig/arch/ia64/Kconfig	2004-08-17 13:31:26.000000000 -0500
> > +++ linux/arch/ia64/Kconfig	2004-08-23 11:39:50.000000000 -0500
> > @@ -189,6 +189,16 @@
> >  	depends on !IA64_HP_SIM
> >  	default y
> >  
> > +config IA64_SGI_SN_XPC
> > +	tristate "Support DMA Messaging between SGI machines"
> 
> Why do you have three different option when the only way they're usefull
> is to have all three enabled at the same time.

By this I asssume you mean that rather than having both IA64_SGI_SN_XPC
and IA64_SGI_SN_XPNET, we should have just one, like IA64_SGI_SN_XP, that
causes all the parts to get built. Correct?


> > +	case xpcMsgReceived:		return "xpcMsgReceived";
> > +	case xpcMsgDelivered:		return "xpcMsgDelivered";
> 
> Please don't add strerror-lookalikes to the kernel.

I'm not clear on this. Do you mean ditch xpc_get_ascii_reason_code()
altogether and have no mapping of a numeric reason code to an ASCII
string?

Or do you mean that the ASCII mapping shouldn't be to the same string,
but rather make the string more meaningful? For example, map
xpcNoHeartbeat to "remote partition has no heartbeat" instead of to
"xpcNoHeartbeat".

If you meant the former: XPC makes dev_info() calls to indicate that a
channel to a partition has connected and disconnected (and why). The why
is a reason code mapped to an ASCII string. Would you prefer that we put
out a numeric value as opposed to a more meaningful ASCII string?


> > +	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
> > +		sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
> > +	}
> 
> A single mutex wouldn't do it?  It doesn't exactly look like it's used in
> fast-paths

Yeah, you're right it's not a fast-path and a single mutex would work.
I kind of like putting the lock within the data structure it's protecting.
When you get the lock, you've already got the data of interest in your
cache (obviously this depends on the size of the structure and where in
the structure the data you're interested in resides). We're not talking
about very much memory lost because of this. (The way it is we only end
up with a total of two semaphores, instead of just one.)

Would you be okay with the thing remaining as it is?


> > +	 */
> > +	if ((ret = sn_register_nofault_code(*(u64 *) pior_func,
> > +					*(u64 *) pior_err_func,
> > +					*(u64 *) pior_err_func, 1, 1)) != 0) {
> 
> Is the strange casting really unavoidable?

Yeah, it is unavoidable. sn_register_nofault_code() is expecting 'the address
of', not 'a pointer to the address of'. I did modify the code a bit so that
the cast is done at another spot, perhaps, this will be more acceptable to
you.

	void __exit
	xp_exit(void)
	{
		u64 func_addr = *(u64 *) xp_nofault_PIOR;
		u64 err_func_addr = *(u64 *) xp_error_PIOR;
                                                                                
		/* unregister the PIO read nofault code region */
		(void) sn_register_nofault_code(func_addr, err_func_addr,
						err_func_addr, 1, 0);
	}


Thanks,
Dean
