From: Matthew Wilcox <willy@debian.org>
Date: Wed, 20 Aug 2003 03:26:11 +0000
Subject: Re: bogus barriers in sym53c8xx_2?
Message-Id: <marc-linux-ia64-106135006819080@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106133886310517@msgid-missing>
In-Reply-To: <marc-linux-ia64-106133886310517@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Aug 19, 2003 at 04:49:53PM -0700, David Mosberger wrote:
> In drivers/scsi/sym53c8xx_2/sym_misc.h we find:
> 
> #elif	defined	__ia64__
> #define __READ_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
> #define __WRITE_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
> 
> based on the comments and the other implementations, these barriers
> are bogus and the "mf.a" should be dropped.
> 
> Anyone know who wrote this code originally and why the mf.a was added?
> 
> mf.a is very slow and should be avoided except were truly needed.

I'm sure Gerard must have written it originally.  It's there
in the earliest version of the sym2 driver I can find --
sym-2.1.16a-for-linux-2.4.13.patch.gz.  A similar barrier is there in
the sym1 driver (drivers/scsi/sym53c8xx_defs.h).  It seems to have been
introduced around 2.4.3 (symbios driver version 1.6b -> 1.7.3a-20010304)

So you're looking for a patch which looks something like this:

- #define __READ_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
- #define __WRITE_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
+ #define __READ_BARRIER()	__asm__ volatile("mf" : : : "memory")
+ #define __WRITE_BARRIER()	__asm__ volatile("mf" : : : "memory")

Or really, might be better to just define them to rmb() and wmb()?

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
