From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 06 Dec 2004 16:13:04 +0000
Subject: Re: [RFC] I/O error handling for userspace
Message-Id: <200412060813.04801.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412030831.25662.jbarnes@engr.sgi.com>
In-Reply-To: <200412030831.25662.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday, December 6, 2004 4:42 am, Hidetoshi Seto wrote:
> > - /* TLB error is only exist in this SAL error record */
> > - recover = (psp->tc && !(psp->cc || psp->bc || psp->rc || psp->uc))
> > - /* other error recovery */
> > -    || (ia64_mca_ucmc_extension
> > -  && ia64_mca_ucmc_extension(
> > -   IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
> > -   &ia64_sal_to_os_handoff_state,
> > -   &ia64_os_to_sal_handoff_state));
>
> Where the ia64_mca_ucmc_extension had go? ... vanished? :-(

Oops, that was accidental.  I'll fix it up.

>
> > +  /* TLB errors are fixed up before we get here, so recover */
> > +  if (psp->tc) {
> > +   recover = 1;
> > +   goto return_to_sal;
> > +  }
> > +
>
> I'm not sure because I hadn't get any logs on crazy error situation, but
> isn't it possible that an error log have both of tc and
> another(cc|bc|rc|uc)? Why we could omit "!(psp->cc || psp->bc || psp->rc ||
> psp->uc)" ?

I'm not sure either, I'll readd the check to make sure we haven't taken 
another error too.

> > +  spin_unlock(&io_range_list_lock);
> > +
> > + return_to_sal:
>
> force_sig_info() takes spinlock in it... I think calling this isn't safe on
> MCA.

You're right, hmm, maybe I have to create a new kernel thread to wakeup and 
send the signals with?  Any suggestions here?  Using a thread would 
invalidate the assumptions I'm making in userspace, since the thread that 
caused the MCA might resume and get the SIGBUS too late to do anything with 
it.  Maybe I just need a version of force_sig_info that does a trylock 
instead and returns a value saying whether the signal was delivered.

> The rest part of the patch (for legacies) seems to be
> functionally-independent. I don't have enough ideas for legacy-maps, but I
> guess you have done good work.

Yeah, I could split that out, that might make more sense.  Thanks for looking!

Jesse
