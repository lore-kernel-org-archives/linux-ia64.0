From: Jack Steiner <steiner@sgi.com>
Date: Wed, 01 Dec 2004 13:29:07 +0000
Subject: Re: [PATCH 2.6.10-rc2] Drop SALINFO_TIMER_DELAY to one minute
Message-Id: <20041201132907.GA6181@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10903.1101872210@kao2.melbourne.sgi.com>
In-Reply-To: <10903.1101872210@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 01, 2004 at 02:36:50PM +1100, Keith Owens wrote:
> Experience with recoverable MCA events shows that a poll interval of 5
> minutes for new MCA/INIT records is a bit too long.  Drop the poll
> interval to one minute.



I'm not convinced that shortening the delay is the right solution.

We are testing OS recovery from double-bit memory errors. Using an error
injection program:

	- a user program injects a double bit error into memory
	- user accesses the memory
	- platform causes an MCA due to bad ECC in memory
	- cpu goes to PAL -> SAL -> OS_MCA
	- OS_MCA recovers the error 
	- OS aborts the user program & logs an error (not sure of
	  the exact sequence here)
	- OS exits from OS_MCA -> SAL -> PAL -> OS
	- (this more-or-less works!!)

The MCA record is still held in SAL. Because of potential deadlock
situations, on the call to OS_MCA the MCA error record is not logged
and cleared. 

After the error is recovered, neither the OS nor SAL raises an 
interrupt to indicate that the OS should log and clear the MCA 
record from the MCA.  The error record remains in SAL until the 
next poll by SALINFO.

The SAL Spec & Error Handling Guide are fuzzy about how this error
should be processed (at least I can't find it). At least some 
of the descriptions are obsolete - they assume the OS will log & 
clear the error as part of OS_MCA handling. As mentioned before, there
are potential deadlock issues in doing this.


It seems to me that either the OS or SAL should do something (ex.,
interrupt, ...) to cause the MCA error to logged/cleared as quickly 
as possible.  Waiting for the next poll interval does not seem like 
the right solution. If too many MCAs (recovered or not) occur 
before the next poll interval, error state will be lost.







	

> 
> Signed-off-by: Keith Owens <kaos@sgi.com>
> 
> Index: linux/arch/ia64/kernel/salinfo.c
> =================================> --- linux.orig/arch/ia64/kernel/salinfo.c	Tue Oct 19 07:54:40 2004
> +++ linux/arch/ia64/kernel/salinfo.c	Wed Dec  1 14:29:16 2004
> @@ -230,8 +230,8 @@ salinfo_log_wakeup(int type, u8 *buffer,
>  	}
>  }
>  
> -/* Check for outstanding MCA/INIT records every 5 minutes (arbitrary) */
> -#define SALINFO_TIMER_DELAY (5*60*HZ)
> +/* Check for outstanding MCA/INIT records every minute (arbitrary) */
> +#define SALINFO_TIMER_DELAY (60*HZ)
>  static struct timer_list salinfo_timer;
>  
>  static void
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


