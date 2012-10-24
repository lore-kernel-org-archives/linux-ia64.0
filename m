From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Date: Wed, 24 Oct 2012 22:14:55 +0000
Subject: ia64 xen comment needs updating
Message-Id: <alpine.DEB.2.02.1210241813320.14474@oneiric>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


  a bit of pedantry -- in arch/ia64/xen/irq_xen.c:

/* Dummy stub. Though we may check XEN_RESCHEDULE_VECTOR before __do_IRQ,
 * it ends up to issue several memory accesses upon percpu data and
 * thus adds unnecessary traffic to other paths.
 */

  __do_IRQ has been gone since 2011, so someone might want to update
that comment.

rday

-- 

====================================
Robert P. J. Day                                 Ottawa, Ontario, CANADA
                        http://crashcourse.ca

Twitter:                                       http://twitter.com/rpjday
LinkedIn:                               http://ca.linkedin.com/in/rpjday
====================================
