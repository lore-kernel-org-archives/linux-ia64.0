From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 29 Jan 2004 13:40:38 +0000
Subject: Re: [PATCH] - Improve SN2 TLB flushing algorithms
Message-Id: <20040129134037.A9040@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040128205912.GA27401@sgi.com>
In-Reply-To: <20040128205912.GA27401@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jan 28, 2004 at 04:36:01PM -0600, Jack Steiner wrote:
> Are you suggesting that we remove the #ifdef OR hide the code
> in a function that, depending on config options, may or may not do anything?

Yes.  And I wonder whether we should just do it unconditionally, but
I'm not really sure.

> > > +		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
> > > +			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
> > 
> > cpu_test_and_set()?
> 
> On IA64 (not sure about other architectures), cpu_test_and_set will always 
> set the bit regardless of it's previous state. That causes the cacheline containing
> the bitmask to be bounced between cpus - possibly unnecessarily. For most

Ok.

