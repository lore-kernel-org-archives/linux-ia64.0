From: Michael Cree <mcree@orcon.net.nz>
Date: Fri, 05 Sep 2014 08:16:48 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140905081648.GB5281@omega>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140712181328.GA8738@redhat.com>
 <54079B70.4050200@hurleysoftware.com>
 <1409785893.30640.118.camel@pasglop>
 <063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>
 <1409824374.4246.62.camel@pasglop>
 <5408E458.3@zytor.com>
 <54090AF4.7060406@hurleysoftware.com>
 <54091B30.2090509@zytor.com>
In-Reply-To: <54091B30.2090509@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On Thu, Sep 04, 2014 at 07:08:48PM -0700, H. Peter Anvin wrote:
> On 09/04/2014 05:59 PM, Peter Hurley wrote:
> > I have no idea how prevalent the ev56 is compared to the ev5.
> > Still we're talking about a chip that came out in 1996.
> 
> Ah yes, I stand corrected.  According to Wikipedia, the affected CPUs
> were all the 2106x CPUs (EV4, EV45, LCA4, LCA45) plus the 21164 with no
> suffix (EV5).  However, we're still talking about museum pieces here.

Yes, that is correct, EV56 is the first Alpha CPU to have the byte-word
extension (BWX) CPU instructions.

It would not worry me if the kernel decided to assume atomic aligned
scalar accesses for all arches, thus terminating support for Alphas
without BWX.

The X server, ever since the libpciaccess change, does not work on
Alphas without BWX.

Debian Alpha (pretty much up to date at Debian-Ports) is still compiled
for all Alphas, i.e., without BWX.  The last attempt to start compiling
Debian Alpha with BWX, about three years ago when Alpha was kicked out
to Debian-Ports resulted in a couple or so complaints so got nowhere.
It's frustrating supporting the lowest common demoninator as many of
the bugs specific to Alpha can be resolved by recompiling with the BWX.
The kernel no longer supporting Alphas without BWX might just be the
incentive we need to switch Debian Alpha to compiling with BWX.

Cheers
Michael.
