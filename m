From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 27 Jan 2006 23:35:14 +0000
Subject: RE: [patch 5/5] fix sn rw_mmr.h to use intrinsic
Message-Id: <B05667366EE6204181EABE9C1B1C0EB5097F1D0D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601270137.k0R1big21236@unix-os.sc.intel.com>
In-Reply-To: <200601270137.k0R1big21236@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote on Friday, January 27, 2006 1:57 AM
> Kenneth> Use ia64 intrinsic for functions in sn/rw_mmr.h.
> Kenneth> Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
> 
> I'll have to test this. However it really doesn't matter much as we
> won't be building the SN kernel with ICC.

When I build a generic kernel, all sn code are pulled in and need to
be compiled.  It would be nice to have sn portion of kernel code free
of asm statement in the source. I heard that gcc is also going in the
direction of implementing intrinsic in the long term.  Or do we have
an option of CONFIG_NON_SGI?  I can cook up something if this is really
what people Want (I suspect not).

- Ken

