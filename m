From: Christoph Hellwig <hch@infradead.org>
Date: Fri, 28 Oct 2005 22:56:09 +0000
Subject: Re: virtualization hooks patch for ia64 2.6.15
Message-Id: <20051028225609.GA14159@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
In-Reply-To: <516F50407E01324991DD6D07B0531AD57E78CC@cacexc12.americas.cpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 28, 2005 at 03:51:15PM -0700, Magenheimer, Dan (HP Labs Fort Collins) wrote:
> Thanks for your reply Christoph.
> 
> See further down in my (admittedly wordy) message.
> Some of the Xen/ia64 functionality is shared with Xen/x86
> and the Xen/x86 patch is coming through a different channel
> so I can't submit a full working Xen/ia64 patch.
> 
> This patch provides an ia64 generic abstraction layer which
> is required when the (multiple architecture) Xen patch
> is ready, but other ia64 virtualization solutions can also
> make use of the hooks too.  Since these hooks are largely
> independent of the Xen patch, I'm submitting them
> separately so that the foundation is ready when the
> rest of the Xen stuff gets submitted.

We have a pretty strong no unused hooks policy for the linux
kernel, as we don't want to put in unused code.  This is more
of a restructuring than actual hooks though, so it's on a borderline.

I'd really prefer to get Xen/ia64 and the Xen common code merged soon
though - it's in a much better shape then Xen/i386 and would give the
common code some badly needed exposure.

