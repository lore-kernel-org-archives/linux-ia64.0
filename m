From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 09 Jul 2004 07:02:26 +0000
Subject: strict rejection of init -> core references causes problems
Message-Id: <16622.17154.117052.31601@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

The recent patch of yours to the kernel module loader is causing some
problems with the netfilter modules.  To recap, with that patch
applied, calls from the core section of a module to an init section
are rejected because that's in general a dangerous thing to do (the
called code may be gone by the time the call gets executed).

I'm not terribly familiar with the netfilter code, but I think the
problem there comes from the fact that some code is shared between
init and exit handlers and that shared code ends up in the module
core.

For example, ip_nat_standalone.c:init_or_cleanup() may call
ip_nat_rule_init(), which is marked as an __init function.  This
happens to be safe because ip_nat_rule_init() is only called during
module-initialization.  Seems to me like a dangerous practice, but if
it's common practice, I suppose we don't have much choice but to allow
calls from core to init sections again.  Perhaps someone from the
netfilter team could comment?

	--david
