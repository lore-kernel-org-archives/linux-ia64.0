From: Michael Raymond <mraymond@sgi.com>
Date: Fri, 01 Apr 2005 19:06:02 +0000
Subject: [PATCH] ULI 2.6.12
Message-Id: <20050401130602.A123752@goliath.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Here's a patch of the ULI code to Tony's pre-2.6.12 tree.
Signed-off-by: Michael A Raymond <mraymond@sgi.com>

    I was able to show that ULIs cannot be scheduled onto other CPUs.  For
every IRQ that a user requests it registers a standard handler.  All IRQ
handlers are called out of do_IRQ().  It's not until do_IRQ() is called that
ia64_eoi() is called to complete the ACK and allow lower priority interrupts
into the system.
    I've added a simple stats program that makes use of ULIs to the support
package on the web site (1).  We've also found a case where their low
perturbation will be useful for user level profiling. I'll be writing that
up next.
     	     					Thanks,
						       Michael
(1) http://oss.sgi.com/projects/uli/
-- 
Michael A. Raymond              Office: (651) 683-3434
Core OS Group                   Real-Time System Software
