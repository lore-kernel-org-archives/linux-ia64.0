From: dann frazier <dannf@hp.com>
Date: Wed, 09 Mar 2005 06:48:39 +0000
Subject: cpu_to_node_map on UP systems
Message-Id: <1110350919.9439.16.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

In 2.6.11, cpu_to_node_map has moved from numa.c to smpboot.c.  Since
smpboot.c isn't built on non-SMP systems, this causes non-smp builds to
fail to link in various places.

I don't know what the right answer is here - resurrect numa.c maybe?

-- 
dann frazier <dannf@hp.com>

