From: Robin Holt <holt@sgi.com>
Date: Wed, 02 Nov 2005 16:23:58 +0000
Subject: Re: [RFC] 4-level page table directories.
Message-Id: <20051102162358.GA23600@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051027041709.GA13193@attica.americas.sgi.com>
In-Reply-To: <20051027041709.GA13193@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 02, 2005 at 08:11:10AM -0800, Luck, Tony wrote:
> >We then started discussing this.  For a normal application with the
> >same virtual address requirements run on a 4 versus a 3 level page table,
> >we would end up with, at most five additional pages of page tables with
> >a single cache-line used in each.
> 
> What about AIM7?  The extra pages would make a difference on a small
> memory machine running thousands of processes.  Is that a concern for
> anyone?

On the aim7 runs I did on a 4 cpu, 4GB machine it was in the noise
range with the 4-level kernel outperforming on nearly an equal number
of points to the 3-level.

Robin
