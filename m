From: Daniel Walker <dwalker@mvista.com>
Date: Wed, 02 May 2007 19:08:01 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <1178132881.12796.385.camel@imap.mvista.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
	 <1177621673.12796.121.camel@imap.mvista.com>  <46320ACD.6090704@hp.com>
	 <1177688158.12796.125.camel@imap.mvista.com>  <463219CD.5040203@hp.com>
	 <1177688931.12796.130.camel@imap.mvista.com>  <463220C8.5060408@hp.com>
	 <1178128707.6183.6.camel@localhost.localdomain>
In-Reply-To: <1178128707.6183.6.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: john stultz <johnstul@us.ibm.com>
Cc: Peter Keilty <peter.keilty@hp.com>, linux-ia64@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

On Wed, 2007-05-02 at 10:58 -0700, john stultz wrote:
> On Fri, 2007-04-27 at 12:11 -0400, Peter Keilty wrote:
> > Daniel Walker wrote:
> > >On Fri, 2007-04-27 at 11:42 -0400, Peter Keilty wrote:
> > >>>There is a read(), and a vread() did you modify the slow syscall path to
> > >>>use the vread()?
> > >>> 
> > >John mentioned that he thought fsys_mmio_ptr could be held in the vread
> > >pointer. vread() is used in x86 for vsyscalls. It looks like you've used
> > >the update_vsyscall() which is also used for vsyscalls. So vread could
> > >also be used .. Have you considered that at all?
> > >  
> > >
> > No, but yes it can be done, overloading the meaning.
> 
> Yea. I'm not really psyched about overloading the vread pointer's use. I
> mentioned it could be done if the #ifdef was objected to, but it seems a
> bit abusive. The #ifdef isn't great, but I think its something I can
> live with for now. At least its explicit.

Use of config options like that is a bad precedence I think, which is
why I commented on it .. Since we have a vread pointer that exists
already, and it's used a very similar purpose it seems like bloat to
just add another pointer.. 

We could change the vread to be a plain void pointer, then let each
architecture use it however they want.

Daniel

