From: Mario Smarduch <cms063@email.mot.com>
Date: Fri, 14 Mar 2003 17:21:21 +0000
Subject: [Linux-ia64] Pre-emption patch for IA-64
Message-Id: <marc-linux-ia64-105590709806101@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
    we're trying to build a reliable low-latency system for use
in telco call processing carrier grade environments (on rx2600
NEBS like servers) . One of the patches we're heavily relying on
is the 'Kernel Preemption' patch. First of we're interested in the
(i) status of this patch on  IA-64 (ii) any issues that you may
have ran into.

Our understanding is that the 'Preemption Patch' offers a systematic
scheduling checkpoint vs. 'low latency patch' which examines
the kernel for any long running code  and based on that
preemption checks are inserted in the kernel proper only (kernel.org)
but addon packages may introduce long latencies. While we plan to
run with 1mS clock tick, low latency  and the preemption
paches, the preemption patch is viewed as a must to gurantee
a bound on 'soft-realtime response'.  Please point out if these
assumption are somewhat correct or is too much emphasis
being placed on the preemption patch, the soft-realtime response
we're looking for is 1mS.

thanks,
    Mario.




