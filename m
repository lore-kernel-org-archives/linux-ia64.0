From: Ken Simpson <ksimpson@ttul.dhs.org>
Date: Tue, 23 May 2000 20:28:18 +0000
Subject: [Linux-ia64] Profiling
Message-Id: <marc-linux-ia64-105590678205104@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi all,

I'm trying to profile a large program using gcc's -pg option and gprof,
but so far have met with little success. It seems that -pg is causing the
compiler to generate a certain amount of crappy code... The -a option (for
basic block profiling) merely causes an internal compiler error.

I am using build 0505 of IA64 TurboLinux. Has anyone else had
trouble using the profiler?

Thanks,
Ken Simpson



