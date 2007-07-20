From: Christoph Hellwig <hch@lst.de>
Date: Fri, 20 Jul 2007 19:12:46 +0000
Subject: revising [patch] add arch_ptrace_stop() hook and use it on ia64
Message-Id: <20070720191246.GA19523@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is anyone ia64-savy interested in revising the patch posted by David in
http://marc.info/?l=linux-kernel&m1575781225495&w=2 ?

This would allow for converting ia64 to the generic ptrace code,
something I would love to see.
