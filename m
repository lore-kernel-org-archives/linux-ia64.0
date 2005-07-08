From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 08 Jul 2005 19:05:18 +0000
Subject: RE: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03DC330D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB6961.2060508@jp.fujitsu.com>
In-Reply-To: <42CB6961.2060508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cc: list was trimmed because I'm only discussing ia64 issue here.

>I'm not familiar with assembly code for intel compiler. So David,
>could you write another macro of ia64_mca_barrier() or a proper
>subroutine instead?

Each of the uses of ia64_mca_barrier() is like this ...

	val = *(... *)addr; /* read from I/O address */

	ia64_mca_barrier(val); /* consume result */

	return val;

Now it appears to me that if you just define ia64_mca_barrier()
as an empty function (in C):

void
ia64_mca_barrier(unsigned long v)
{
}

then this will force a consumption of the value (since the compiler
will have to copy it from whatever register it was in to an "out"
register to pass to the function).  Without the call, then the
compiler will probably allocate "r8" for "val" ... so there will
be no consumption.

Even though the function is empty, it deserves a few lines of comment
to describe how it achieves its objective, even though it does nothing!

-Tony

P.S. I think your mailer is mangling white-space.  When I tried to
apply the patches I got many rejects.  An example of the problem
in part 1 is (of course my mailer will mangle this too, so I'll
describe in words ... the two "extern" lines have two leading spaces
when there should only be one.  The blank line that follows should
also have a single space on it, but it doesn't).

--- linux-2.6.13-rc1.orig/include/asm-generic/iomap.h
+++ linux-2.6.13-rc1/include/asm-generic/iomap.h
@@ -65,4 +65,36 @@ struct pci_dev;
  extern void __iomem *pci_iomap(struct pci_dev *dev, int bar, unsigned long max);
  extern void pci_iounmap(struct pci_dev *dev, void __iomem *);

+/*
