From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 01 Jun 2005 22:48:54 +0000
Subject: RE: [patch 0/4] ia64 SPARSEMEM
Message-Id: <17054.15190.531449.308712@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050523175031.GC2783@localhost.localdomain>
In-Reply-To: <20050523175031.GC2783@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 31 May 2005 11:14:22 -0700, Dave Hansen <haveblue@us.ibm.com> said:

  Dave> The pagetables that are walked in the TLB miss handler (for
  Dave> vmem_map[]) could just as easily be a set of two-level
  Dave> mem_section tables that are walked in software.

SPARSEMEM might be a lot more interesting if it could "degenerate"
into VIRTUAL_MEM_MAP.  That is, on platforms with enough virtual
space, you should be able to let the hardware/MMU-subsystem do the
translation.

	--david
