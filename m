From: Anton Blanchard <anton@samba.org>
Date: Wed, 20 Aug 2003 03:43:18 +0000
Subject: Re: bogus barriers in sym53c8xx_2?
Message-Id: <marc-linux-ia64-106135129219840@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106133886310517@msgid-missing>
In-Reply-To: <marc-linux-ia64-106133886310517@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> I'm sure Gerard must have written it originally.  It's there
> in the earliest version of the sym2 driver I can find --
> sym-2.1.16a-for-linux-2.4.13.patch.gz.  A similar barrier is there in
> the sym1 driver (drivers/scsi/sym53c8xx_defs.h).  It seems to have been
> introduced around 2.4.3 (symbios driver version 1.6b -> 1.7.3a-20010304)
> 
> So you're looking for a patch which looks something like this:
> 
> - #define __READ_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
> - #define __WRITE_BARRIER()	__asm__ volatile("mf.a; mf" : : : "memory")
> + #define __READ_BARRIER()	__asm__ volatile("mf" : : : "memory")
> + #define __WRITE_BARRIER()	__asm__ volatile("mf" : : : "memory")
> 
> Or really, might be better to just define them to rmb() and wmb()?

I suspect so, the powerpc ones are overkill too:

#define __READ_BARRIER()        __asm__ volatile("eieio; sync" : : : "memory")
#define __WRITE_BARRIER()       __asm__ volatile("eieio; sync" : : : "memory")

Anton
