From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 05 Sep 2014 20:43:12 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140905204312.GA5001@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5408E458.3@zytor.com>
 <54090AF4.7060406@hurleysoftware.com>
 <54091B30.2090509@zytor.com>
 <20140905081648.GB5281@omega>
 <20140905180950.GU5001@linux.vnet.ibm.com>
 <540A05F7.1070202@hurleysoftware.com>
 <20140905190506.GV5001@linux.vnet.ibm.com>
 <8CA974F497CA064FA9926E10ABCC061F05F97E7B77@MAILSJ4.global.cadence.com>
 <540A19B8.4010907@hurleysoftware.com>
 <540A1E6C.2020005@zytor.com>
In-Reply-To: <540A1E6C.2020005@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Hurley <peter@hurleysoftware.com>, Marc Gauthier <marc@cadence.com>, Michael Cree <mcree@orcon.net.nz>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>

On Fri, Sep 05, 2014 at 01:34:52PM -0700, H. Peter Anvin wrote:
> On 09/05/2014 01:14 PM, Peter Hurley wrote:
> > 
> > Here's how I read the two statements.
> > 
> > First, the commit message:
> > 
> > "It [this commit] documents that CPUs [supported by the Linux kernel]
> > _must provide_ atomic one-byte and two-byte naturally aligned loads and stores."
> > 
> > Second, in the body of the document:
> > 
> > "The Linux kernel no longer supports pre-EV56 Alpha CPUs, because these
> > older CPUs _do not provide_ atomic one-byte and two-byte loads and stores."
> > 
> 
> Does this apply in general or only to SMP configurations?  I guess
> non-SMP configurations would still have problems if interrupted in the
> wrong place...

And preemption could cause problems, too.  So I believe that it needs
to be universal.

							Thanx, Paul

