From: Jack Steiner <steiner@sgi.com>
Date: Wed, 10 Oct 2001 13:59:36 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805316@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> What if I were to get rid of the rate limited logging for both the
> unaligned and fpswa handlers?  Then there could just be a NOPRINT option
> and a signal option for each; the default behavior would be to log all
> messages.  If you'd rather not get rid of it, then I'll just send a patch
> to enable NOPRINT for fpswa (similar to what the unaligned handler does
> now) and a signal option.

IMHO, the default for FPSWA fault (& probably unaligned access) should be OFF.
Lots of apps cause FP faults. AIM7, for example, causes faults at a fairly high
rate. I doubt that any server site would like to see the log polluted with 
these errors - especially since there is no way to identify the offending app.

There should be a way a site can change the default logging behavior & have it
apply to ALL tasks.. 


Remember that FPSWA is invoked for numerous reasons that are NOT necessarily 
errors in the application. (AIM7 generates FPSWA faults when it divides a
very small number by 2.0). Intel doesnt even specify all the conditions that cause
FPSWA to be invoked.

As far as rate limited vs full logging, I like rate limited. Otherwise, you can
flood the system with messages. If you are truly trying to debug an app & identify 
places that cause faults, the SIGNAL method should be used by the app. 
That way, additional info such as traceback & arguments can be captured. 

---

After thinking about it for a while, it seems to me that the kernel logging options
should be orthoginal to the user SIGNAL option. A site should be able to select
NOPRINT/RATE-LOGGING/FULL_LOGGING. Independently, the user to be able to select 
SIGNAL/NO_SIGNAL/PRINTALL. 

The kernel logging option should NOT be a task attribute. Just have
a static flag that controls logging. The value of the flag is 
NOPRINT/RATEPRINT/FULLPRINT. Default should be NOPRINT. This option should
be able to be changed via operator command (/proc).

Independently, users might want to select SIGNAL/NOSIGNAL/(PRINT?) 
for faults from their application. 


> 
> Does anyone else have an opinion on the rate limited logging for the
> unaligned and fpswa handlers?  Some people have told me that they don't
> think it's useful for admins or users to have some of the messages but not
> all of them.
> 
> Thanks,
> Jesse
> 
> On Tue, 9 Oct 2001, David Mosberger wrote:
> 
> > >>>>> On Tue, 9 Oct 2001 10:38:57 -0700, Jesse Barnes <jbarnes@sgi.com> said:
> > 
> >   Jesse> Wouldn't that mean you could only do one at a time,
> >   Jesse> i.e. you'd be stuck with the rate limiting code even if you
> >   Jesse> just wanted a signal, since there'd be no way to say NOPRINT
> >   Jesse> | SIGFPE?  I'm really just trying to fill the needs of our
> >   Jesse> application programmers, who say they want to get all the
> >   Jesse> messages and/or get a signal.
> > 
> > No, I don't think so:
> > 
> > 	DEFAULT:	log message (with rate limit)
> > 	NOPRINT:	be quiet about fixups (not rate limited)
> > 	SIGNAL:		send signal (not rate limited)
> > 	PRINTALL:	log message (not rate limited)
> > 
> > In other words, the rate-limiting only applies for the DEFAULT setting.
> > 
> > 	--david
> > 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


