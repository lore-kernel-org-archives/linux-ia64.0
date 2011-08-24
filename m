From: Matt Fleming <matt@console-pimps.org>
Date: Wed, 24 Aug 2011 14:39:56 +0000
Subject: How performance critical is fsys_rt_sigprocmask()?
Message-Id: <1314196796.3611.38.camel@mfleming-mobl1.ger.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I'm looking at the code code in fsys_rt_sigprocmask() and I'm wondering
whether it really needs to be implemented in assembly. I recently posted
a patch series that converted code modifying current->blocked to use the
new set_current_blocked() helper but initially missed the code in
fsys_rt_sigprocmask() because it's not written in C.

It seems this sort of thing has happened before too, e.g. with the
ticket lock implementation as seen in commit f574c8431917 ("[IA64] fix
siglock"), presumably for the same reasons.

So I was wondering, from a code maintenance perspective, would it make
sense to delete the custom implementation of sys_rt_sigprocmask() and
use the generic one? Or does that function genuinely have a need to be
written in hand-optimised assembly?

-- 
Matt Fleming, Intel Open Source Technology Center

