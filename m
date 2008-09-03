From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 03 Sep 2008 23:03:27 +0000
Subject: probe_kernel_address() causes MCA on bogus address
Message-Id: <1220483007.3254.51.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a noticed side effect of trying to redo the function pointer
handling.  This code:

        void *p1 = 0xdeadbeefdead0000, *p2 = 0xfeeddeadfeedbeef;

        probe_kernel_address(p1, p2);

causes an immediate MCA and reboot on my HP zx2000 wherever I execute it
in the kernel.  It's supposed to return -EFAULT.

James


