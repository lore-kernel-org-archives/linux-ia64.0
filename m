From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 06 Dec 2001 21:15:29 +0000
Subject: Re: [Linux-ia64] multimedia timer interface
Message-Id: <marc-linux-ia64-105590698805633@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805631@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805631@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Oops, thanks.  I blindly copied that one from the draft spec.  I also
forgot to #define _LINUX_MMTIMER_H right after the #ifndef.  The
comments for commands that return a boolean should probably read
something like 'returns nonzero if true, zero if false' as well.

Jesse

On Thu, Dec 06, 2001 at 01:11:01PM -0800, Luck, Tony wrote:
> The prefix for 10**-15 is "femto", not "fempto".  See
> 
> 	http://physics.nist.gov/cuu/Units/prefixes.html
> 
> -Tony
> 
> -----Original Message-----
> From: Jesse Barnes [mailto:jbarnes@sgi.com]
> Sent: Thursday, December 06, 2001 12:51 PM
> To: linux-ia64@linuxia64.org; davidm@hpl.hp.com
> Subject: [Linux-ia64] multimedia timer interface
> 
> 
> David, we talked awhile back about a generic timer interface that we
> could use on SN platforms as a non-drifting replacement for the ITC.
> I've taken a look at the Intel multimedia timer spec like you
> suggested and came up with the following header file.  I've
> implemented it on our system with some glibc changes to the hp timing
> routines and things seem to work fine.  I'd like to get people's
> comments on the ioctl interface though, because I'd like it to be
> useful on other platforms as well.  Also, do you need me to resend the
> salinfo patch I posted awhile back or are you just waiting for the SAL
> spec to get updated?  I noticed it wasn't in the latest patch.
> 
> Thanks,
> Jesse
> 
> /*
>  * Intel Multimedia Timer device interface
>  *
>  * This file is subject to the terms and conditions of the GNU General
> Public
>  * License.  See the file "COPYING" in the main directory of this archive
>  * for more details.
>  *
>  * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
>  *
>  * This file should define an interface compatible with the IA-PC Multimedia
> 
>  * Timers Draft Specification (rev. 0.97) from Intel.  Note that some
>  * hardware may not be able to safely export its registers to userspace, 
>  * so the ioctl interface should support all necessary functionality.
>  *
>  * 11/01/01 - jbarnes - initial revision
>  */
> 
> #ifndef _LINUX_MMTIMER_H
> 
> /* name of the device, usually in /dev */
> #define MMTIMER_NAME "mmtimer"
> #define MMTIMER_FULLNAME "/dev/mmtimer"
> #define MMTIMER_DESC "IA-PC Multimedia Timer"
> #define MMTIMER_VERSION "1.0"
> 
> /*
>  * Used by the user to setup an alarm
>  */
> typedef struct mmtimer_alarm {
> 	int id;
> 	unsigned long value;
> 	int signo;
> } mmtimer_alarm_t;
> 
> /*
>  * Breakdown of the ioctl's available.  An 'optional' next to the command
>  * indicates that supporting this command is optional, while 'required'
>  * commands must be implemented if conformance is desired.
>  *
>  * MMTIMER_GETOFFSET - optional
>  *   Should return the offset (relative to the start of the page where the 
>  *   registers are mapped) for the counter in question.
>  *
>  * MMTIMER_GETRES - required
>  *   The resolution of the clock in fempto (10E-15) seconds
>  *
>  * MMTIMER_GETFREQ - required
>  *   Frequency of the clock in Hz
>  *
>  * MMTIMER_GETLEGACYIRQ - required
>  *   Returns 1 if the device can route IRQs to legacy interrupt controllers
>  *
>  * MMTIMER_GETBITS - required
>  *   Number of bits in the clock's counter
>  *
>  * MMTIMER_GETNUM - required
>  *   Number of comparators available
>  *
>  * MMTIMER_MMAPAVAIL - required
>  *   Returns 1 if the registers can be mmap'd into userspace
>  *
>  * MMTIMER_SETPERIODIC - required
>  *   Sets the comparator in question to the value specified.
>  *   The interrupt handler will add the value specified to the
>  *   comparator after a match.
>  *
>  * MMTIMER_SETONESHOT - required
>  *   Like the above, but the comparator is not updated after the match.
>  *
>  * MMTIMER_GETCOUNTER - required
>  *   Gets the current value in the counter
>  */
> #define MMTIMER_IOCTL_BASE 'm'
> 
> #define MMTIMER_GETOFFSET _IO(MMTIMER_IOCTL_BASE, 0)
> #define MMTIMER_GETRES _IOR(MMTIMER_IOCTL_BASE, 1, unsigned long)
> #define MMTIMER_GETFREQ _IOR(MMTIMER_IOCTL_BASE, 2, unsigned long)
> #define MMTIMER_GETLEGACYIRQ _IO(MMTIMER_IOCTL_BASE, 3)
> #define MMTIMER_GETBITS _IO(MMTIMER_IOCTL_BASE, 4)
> #define MMTIMER_GETNUM _IO(MMTIMER_IOCTL_BASE, 5)
> #define MMTIMER_MMAPAVAIL _IO(MMTIMER_IOCTL_BASE, 6)
> #define MMTIMER_SETPERIODIC _IOW(MMTIMER_IOCTL_BASE, 7, mmtimer_alarm_t)
> #define MMTIMER_SETONESHOT _IOW(MMTIMER_IOCTL_BASE, 8, mmtimer_alarm_t)
> #define MMTIMER_GETCOUNTER _IOR(MMTIMER_IOCTL_BASE, 9, unsigned long)
> 
> /*
>  * An mmtimer verification program.  WARNINGs are ok, but ERRORs indicate
>  * that the device doesn't fully support the interface defined here.
>  */
> #ifdef _MMTIMER_TEST_PROGRAM
> 
> #include <stdio.h>
> #include <unistd.h>
> #include <errno.h>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> 
> #include <sys/ioctl.h>
> 
> #include "mmtimer.h"
> 
> int main(int argc, char *argv[])
> {
> 	int result, fd;
> 	unsigned long val = 0;
> 	unsigned long i;
> 
> 	if((fd = open("/dev/"MMTIMER_NAME, O_RDONLY)) = -1) {
> 		printf("failed to open /dev/%s", MMTIMER_NAME);
> 		return 1;
> 	}
> 
>         /*
>          * How many comparators are there?
>          */
>         if((result = ioctl(fd, MMTIMER_GETNUM, 0)) != -ENOSYS)
>                 printf("comparators available: %d\n", result);
>         else
>                 printf("ERROR: no comparators available\n");
> 
>         /*
>          * Can we mmap in the counter?
>          */
>         if((result = ioctl(fd, MMTIMER_MMAPAVAIL, 0)) = 1) {
>                 printf("mmap available\n");
> 	        /* ... so try getting the offset for each clock */
> 	        if((result = ioctl(fd, MMTIMER_GETOFFSET, 0)) != -ENOSYS) 
> 	                printf("offset: %d\n", result);
> 	        else
> 	                printf("WARNING: offset unavailable for clock\n");
> 	}
>         else
>                 printf("WARNING: mmap unavailable\n");
> 
> 	/*
> 	 * Get the resolution in femptoseconds
> 	 */
>         if((result = ioctl(fd, MMTIMER_GETRES, &val)) != -ENOSYS)
>                 printf("resolution: %ld femptoseconds\n", val);
>         else
>                 printf("ERROR: failed to get resolution\n");
> 
> 	/*
> 	 * Get the frequency in Hz
> 	 */
>         if((result = ioctl(fd, MMTIMER_GETFREQ, &val)) != -ENOSYS)
> 		if(val < 10000000) /* less than 10 MHz? */
> 			printf("ERROR: frequency only %ld MHz, should be >> 10 MHz\n", val/1000000);
> 		else
> 			printf("frequency: %ld MHz\n", val/1000000);
>         else
>                 printf("ERROR: failed to get frequency\n");
> 
> 	/*
> 	 * Does this interface have legacy IRQ support?
> 	 */
>         if((result = ioctl(fd, MMTIMER_GETLEGACYIRQ, 0)) = 1)
>                 printf("legacy IRQ support available\n");
>         else
>                 printf("no legacy IRQ support available\n");
> 
> 	/*
> 	 * How many bits in the counter?
> 	 */
>         if((result = ioctl(fd, MMTIMER_GETBITS, 0)) != -ENOSYS)
>                 printf("bits in counter: %d\n", result);
>         else
>                 printf("ERROR: can't get number of bits in counter\n");
> 
> 	if((result = ioctl(fd, MMTIMER_GETCOUNTER, &val)) != -ENOSYS)
> 		printf("counter value: %ld\n", val);
> 	else
> 		printf("ERROR: can't get counter value\n");
> 
> 	return 0;
> }
> 
> #endif /* _MMTIMER_TEST_PROGRM */
> 
> #endif /* _LINUX_MMTIMER_H */
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64

