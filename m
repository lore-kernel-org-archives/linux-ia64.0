From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 04 Feb 2006 00:28:35 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <200602040028.k140SZg17845@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote on Friday, February 03, 2006 4:16 PM
> >Are there any correctness issues?  Any place where we access a
> >per-cpu variable where we absolutely cannot take an Alt-DTLB fault?
> 
> mca_asm.S, GET_IA64_MCA_DATA().  ia64_mca_data is per cpu and is
> accessed right from the start of the MCA/INIT handlers, with psr.i,
> psr.ic both 0.

Ouch, can I turn off psr.dt, then access ia64_mca_data in physical
mode, and switch psr.dt back on?  Are there any ill effect this
could cause?

- Ken

