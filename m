From: "Robboy, David G" <david.g.robboy@intel.com>
Date: Wed, 23 May 2001 21:54:30 +0000
Subject: RE: [Linux-ia64] 2.4.4 stability on Lions
Message-Id: <marc-linux-ia64-105590693005664@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005642@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005642@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> Thanks Asit.  Is there a way to temporarily disable the on 
> board NIC?  Our
> installer always defaults to eth0 for network installs.  As 
> luck would have
> it, the e100 modules get loaded before our add in 3com.

If you build a kernel with the 3com driver linked in (not a module), and
don't configure in the e100, it should work.  I just did that with a Tulip
card and it's working.

David

> -----Original Message-----
> From: Michael Madore [mailto:mmadore@turbolinux.com]
> Sent: Wednesday, May 23, 2001 1:54 PM
> To: Mallick, Asit K
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] 2.4.4 stability on Lions
> 
> 
> Thanks Asit.  Is there a way to temporarily disable the on 
> board NIC?  Our
> installer always defaults to eth0 for network installs.  As 
> luck would have
> it, the e100 modules get loaded before our add in 3com.
> 
> On Wed, May 23, 2001 at 01:06:21PM -0700, Mallick, Asit K wrote:
> > Mike,
> > 
> > A workaround should be implemented and I will need to 
> investigate on this.
> > In the mean time you can use an add-on Intel 10/100 
> ethernet card and this
> > problem is not present.
> > 
> > Thanks,
> > Asit
> > 
> > 
> > > -----Original Message-----
> > > From: Michael Madore [mailto:mmadore@turbolinux.com]
> > > Sent: Wednesday, May 23, 2001 11:23 AM
> > > To: David Mosberger
> > > Cc: linux-ia64@linuxia64.org
> > > Subject: Re: [Linux-ia64] 2.4.4 stability on Lions
> > > 
> > > 
> > > What I meant to say was it gets violently ill. ;-)
> > > 
> > > You are correct, it "get's stuck"  It is the same problem 
> > > that was discussed
> > > on the list in February.
> > > 
> > > On Wed, May 23, 2001 at 11:21:25AM -0700, David Mosberger wrote:
> > > > >>>>> On Wed, 23 May 2001 09:43:10 -0700, Michael Madore 
> > > <mmadore@turbolinux.com> said:
> > > > 
> > > >   Michael> Well, almost everything.  I still have the 
> > > problem with the
> > > >   Michael> onboard e100 network adapter.  This is the 
> problem where
> > > >   Michael> transferring certain files via nfs causes nfs to die.
> > > > 
> > > > Die or "get stuck"?  It shouldn't die.
> > > > 
> > > > 	--david
> > > 
> > > -- 
> > > Mike Madore
> > > Senior Software Engineer
> > > TurboLinux, Inc.
> > > (650)228-5203
> > > 
> > > _______________________________________________
> > > Linux-IA64 mailing list
> > > Linux-IA64@linuxia64.org
> > > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> > > 
> > 
> > 
> > _______________________________________________
> > Linux-IA64 mailing list
> > Linux-IA64@linuxia64.org
> > http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 
> -- 
> Mike Madore
> Senior Software Engineer
> TurboLinux, Inc.
> (650)228-5203
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


