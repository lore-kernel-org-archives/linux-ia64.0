From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Fri, 09 Nov 2001 01:31:47 +0000
Subject: RE: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805459@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David/Jesse,

We have got an agreement with the Intel SAL team on defining the bit 3 of
the SAL platform features as the following:

	0 - no ITC drift
	1 - ITC may drift

We will get this definition reviewed by other SAL users/members and do not
expect any problem with the review. The definition should not affect most of
the FWs since this bit is already set to 0 and ITCs do not drift. The
specification will be updated and currently it is planned for Q1 next year.

Thanks,
Asit


> -----Original Message-----
> From: Jesse Barnes [mailto:jbarnes@sgi.com]
> Sent: Monday, November 05, 2001 5:03 PM
> To: David Mosberger
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] itc sync & clock_*
> 
> 
> Yeah, sounds good.  I'm not sure about the name too, hopefully the
> firmware folks will come up with something better.  
> ITC_MAY_DRIFT seems a
> little clunky...
> 
> Jesse
> 
> On Mon, 5 Nov 2001, David Mosberger wrote:
> 
> > >>>>> On Wed, 31 Oct 2001 11:41:58 -0800, Jesse Barnes 
> <jbarnes@sgi.com> said:
> > 
> >   Jesse> Here's a patch against 2.4.13+ia64 to export the 
> sal platform
> >   Jesse> features to a directory in /proc.  Please let me 
> know if it's
> >   Jesse> ok; I'll start working on the clock driver if it is.
> > 
> > Looks great to me!  I'll hold off with applying the patch until the
> > firmware interface has been finalized, if that's all right with you.
> > 
> > Thanks,
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

