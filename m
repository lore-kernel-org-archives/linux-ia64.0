From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 05 Sep 2014 20:12:30 +0000
Subject: Re: bit fields && data tearing
Message-Id: <20140905201230.GV4783@worktop.ger.corp.intel.com>
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
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Michael Cree <mcree@orcon.net.nz>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Laight <David.Laight@ACULAB.COM>, Jakub Jelinek <jakub@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Paul Mackerras <paulus@samba.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Miroslav Franc <mfranc@redhat.com>, Richard Henderson <rth@twiddle.net>, linux-alpha@vger.kernel.org

On Fri, Sep 05, 2014 at 04:01:35PM -0400, Peter Hurley wrote:
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
> 

 depends BROKEN 

or is that deprecated?
