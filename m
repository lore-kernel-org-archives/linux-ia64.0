From: john stultz <johnstul@us.ibm.com>
Date: Tue, 18 Nov 2003 01:02:55 +0000
Subject: Re: [RFC][PATCH] linux-2.4.23-pre9_ia64-cyclone_A0
Message-Id: <marc-linux-ia64-106911773504950@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106911773604958@msgid-missing>
In-Reply-To: <marc-linux-ia64-106911773604958@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Resent to the proper mailing list]

On Mon, 2003-11-17 at 16:23, Bjorn Helgaas wrote:
> On Friday 14 November 2003 6:24 pm, john stultz wrote:
> > 	This patch was developed for the distros to support the cyclone time
> > source on IBM x455 systems. x455 systems are multi-node NUMA systems
> > which suffer from unsynced ITCs, which can cause non-monotonically
> > increasing results from gettimeofday(). Very similar code was
> > implemented in the i386 arch to resolve the same issue on x440s.
> > ...
> > Any comments or feedback would be appreciated. 
> 
> There's a generic infrastructure for this in 2.5:
> 	http://linux.bkbits.net:8080/linux-2.5/cset@1.1046.203.22?nav=index.html|src/.|src/include|src/include/linux|related/include/linux/timex.h

Yep, I'm looking at exactly that for my 2.5 patch. But thanks for the
pointer.

> SGI uses a similar design in 2.4, but apparently there are some
> issues with it:
> 	http://www.gelato.unsw.edu.au/linux-ia64/0310/6973.html
> 
> I'd like to see those issues resolved and the Cyclone support
> put into the same framework as the SGI work.

Hmmm. I think I've grasped the issue there. It seems the problem is not
calculating the equivalent of delay_at_last_interrupt found in the i386
time code. I'll see if I cannot come up with something similar.

Also I'd definitely like to share more infrastructure w/ the SN2 folks,
is there a pointer to their 2.4 gettimeoffset() patch around?

thanks
-john


