From: dann frazier <dannf@dannf.org>
Date: Wed, 09 Mar 2005 06:10:57 +0000
Subject: find_pernode_space() UP compile error
Message-Id: <1110348657.9439.3.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A generic 2.6.11 w/ CONFIG_SMP=n:

arch/ia64/mm/discontig.c: In function `find_pernode_space':
arch/ia64/mm/discontig.c:370: error: `__per_cpu_offset' undeclared
(first use in this function)
arch/ia64/mm/discontig.c:370: error: (Each undeclared identifier is
reported only once
arch/ia64/mm/discontig.c:370: error: for each function it appears in.)

I don't know how much of this function is a no-op on UP systems; though
discontig.c compiles w/ an #ifdef CONFIG_SMP around the __per_cpu_offset
assignment.

-- 
dann frazier <dannf@dannf.org>

