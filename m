From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 05 Sep 2014 20:19:06 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140905201906.GY5001@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <063D6719AE5E284EB5DD2968C1650D6D17487172@AcuExch.aculab.com>
 <1409824374.4246.62.camel@pasglop>
 <5408E458.3@zytor.com>
 <54090AF4.7060406@hurleysoftware.com>
 <54091B30.2090509@zytor.com>
 <20140905081648.GB5281@omega>
 <20140905180950.GU5001@linux.vnet.ibm.com>
 <20140905183109.GA5497@linux.vnet.ibm.com>
 <20140905195234.GT4783@worktop.ger.corp.intel.com>
 <540A169F.40906@hurleysoftware.com>
In-Reply-To: <540A169F.40906@hurleysoftware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Hurley <peter@hurleysoftware.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Michael Cree <mcree@orcon.net.nz>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On Fri, Sep 05, 2014 at 04:01:35PM -0400, Peter Hurley wrote:
> On 09/05/2014 03:52 PM, Peter Zijlstra wrote:
> > On Fri, Sep 05, 2014 at 11:31:09AM -0700, Paul E. McKenney wrote:
> >> compiler: Allow 1- and 2-byte smp_load_acquire() and smp_store_release()
> >>
> >> CPUs without single-byte and double-byte loads and stores place some
> >> "interesting" requirements on concurrent code.  For example (adapted
> >> from Peter Hurley's test code), suppose we have the following structure:
> >>     
> >>     	struct foo {
> >>     		spinlock_t lock1;
> >>     		spinlock_t lock2;
> >>     		char a; /* Protected by lock1. */
> >>     		char b; /* Protected by lock2. */
> >>     	};
> >>     	struct foo *foop;
> >>     
> >> Of course, it is common (and good) practice to place data protected
> >> by different locks in separate cache lines.  However, if the locks are
> >> rarely acquired (for example, only in rare error cases), and there are
> >> a great many instances of the data structure, then memory footprint can
> >> trump false-sharing concerns, so that it can be better to place them in
> >> the same cache cache line as above.
> >>
> >> But if the CPU does not support single-byte loads and stores, a store
> >> to foop->a will do a non-atomic read-modify-write operation on foop->b,
> >> which will come as a nasty surprise to someone holding foop->lock2.  So we
> >> now require CPUs to support single-byte and double-byte loads and stores.
> >> Therefore, this commit adjusts the definition of __native_word() to allow
> >> these sizes to be used by smp_load_acquire() and smp_store_release().
> > 
> > So does this patch depends on a patch that removes pre EV56 alpha
> > support? I'm all for removing that, but I need to see the patch merged
> > before we can do this.
> 
> I'm working on that but Alpha's Kconfig is not quite straightforward.
> 
> 
> ... and I'm wondering if I should _remove_ pre-EV56 configurations or
> move the default choice and produce a warning about unsupported Alpha
> CPUs instead?

I suspect that either would work, given that the Alpha community is
pretty close-knit.  Just setting the appropriate flag to make the
compiler generate one-byte and two-byte loads and stores would
probably suffice.  ;-)

							Thanx, Paul

> Regards,
> Peter Hurley
> 
> [ How does one do a red popup in kbuild?
>   The 'comment' approach is too subtle.
> ]
> 
> 
> 

