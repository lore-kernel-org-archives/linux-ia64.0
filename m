From: Michael Cree <mcree@orcon.net.nz>
Date: Fri, 05 Sep 2014 20:39:51 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140905203951.GA4053@omega>
List-Id: <linux-ia64.vger.kernel.org>
References: <1409824374.4246.62.camel@pasglop>
 <5408E458.3@zytor.com>
 <54090AF4.7060406@hurleysoftware.com>
 <54091B30.2090509@zytor.com>
 <20140905081648.GB5281@omega>
 <20140905180950.GU5001@linux.vnet.ibm.com>
 <540A05F7.1070202@hurleysoftware.com>
 <20140905190506.GV5001@linux.vnet.ibm.com>
 <8CA974F497CA064FA9926E10ABCC061F05F97E7B77@MAILSJ4.global.cadence.com>
 <540A19B8.4010907@hurleysoftware.com>
In-Reply-To: <540A19B8.4010907@hurleysoftware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Marc Gauthier <marc@cadence.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>

On Fri, Sep 05, 2014 at 04:14:48PM -0400, Peter Hurley wrote:
> Second, in the body of the document:
> 
> "The Linux kernel no longer supports pre-EV56 Alpha CPUs, because these
> older CPUs _do not provide_ atomic one-byte and two-byte loads and stores."

Let's be clear here, the pre-EV56 Alpha CPUs do provide an atomic
one-byte and two-byte load and store; it's just that one must use
locked load and store sequences to achieve atomicity.  The point,
I think, is that the pre-EV56 Alpha CPUs provide non-atomic one-byte
and two-byte load and stores as the norm, and that is the problem.

Cheers
Michael.
