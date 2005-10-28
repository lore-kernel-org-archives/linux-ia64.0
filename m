From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 28 Oct 2005 17:59:03 +0000
Subject: RE: ia64 get_mmu_context patch
Message-Id: <200510281759.j9SHx3g23205@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
In-Reply-To: <200510271728.j9RHScS0002221922@kitche.zk3.dec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Peter Keilty wrote on Friday, October 28, 2005 7:50 AM
> > This printk is spurious.  When I first read it, my reaction 
> > is: rid as in region register is architecturally defined at 
> > maximum 24 bits.  Printing 21-bit for rid is misleading.  We 
> > currently use 8 rid number per process.
> > So 21 bit for context number is the max.  max_ctx will never 
> > exceed 1<<21.
> > Suggest this printk to be dropped.
> 
> I add that per mail with Tony, He suggested that we might limit
> the bitmap size so that if the rid size was increase in future
> hardware that a Giga byte Would not be allocated. The printk was
> to let people know that the rid was being limited to 2^21 if the
> rid was enlarged.

If I were you, I would try to convince Tony with the argument I
presented in my earlier post :-)

- Ken

