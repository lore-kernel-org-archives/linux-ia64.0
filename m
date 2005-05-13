From: Russ Anderson <rja@sgi.com>
Date: Fri, 13 May 2005 16:56:36 +0000
Subject: [RFC] Override CPE & CMC thresholding defaults
Message-Id: <200505131656.j4DGuafS13337777@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CPE (Corrected Processor Errors) and CMC (Corrected Machine Checks)
handling has thresholding to prevent a burst of errors (such as a
solid single bit) from overwhelming Linux with interrupts & logging
overhead.  When the threshold is exceeded, linux goes into polling
mode.  The values are currently hardcoded.

#define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
#define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
#define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
#define CPE_HISTORY_LENGTH    5
#define CMC_HISTORY_LENGTH    5

Those values may be appropriate for some configurations, but
may not for others.  For example, a CPE threshold of 5 may
be low for a system with 4 terabytes of memory.  Given the
variety of system sizes, it may be difficult to agree on
hardcoded defaults that fit all systems.

One alternative would be /proc/sys/kernel/ entries, so
that the default values could be overridden.  For example,
/proc/sys/kernel/cpe_threshold would override the default
CPE threshhold of 5.

Would there be any objection to creating /proc/sys/kernel/
entries to override the hardcoded default values?

Thanks,
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
