From: n0ano@indstorage.com
Date: Wed, 10 Oct 2001 14:18:00 +0000
Subject: Re: [Linux-ia64] Re: prctl patch for fpu faults
Message-Id: <marc-linux-ia64-105590698805315@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805302@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It depends upon the frequency that the FPSWA and unaligned faults
occur.  My experience is that, if you get any of these messages, you
get a lot o f them.  I like the 4 options David proposes, this
gives you the flexibility to manage these events in any way you
wish.  I like to run with the default (rate limited messages) setting -
if any messages come out I know there is something that needs to
be looked at but the system's `printk' buffer doesn't get flooded
with duplicated messages.

On Tue, Oct 09, 2001 at 02:40:49PM -0700, Jesse Barnes wrote:
> What if I were to get rid of the rate limited logging for both the
> unaligned and fpswa handlers?  Then there could just be a NOPRINT option
> and a signal option for each; the default behavior would be to log all
> messages.  If you'd rather not get rid of it, then I'll just send a patch
> to enable NOPRINT for fpswa (similar to what the unaligned handler does
> now) and a signal option.
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

-- 
Don Dugger
"Censeo Toto nos in Kansa esse decisse." - D. Gale
n0ano@indstorage.com
Ph: 303/652-0870x117

