From: Keith Owens <kaos@sgi.com>
Date: Thu, 01 Sep 2005 02:31:49 +0000
Subject: Re: [PATCH 2.6.13 0/7] MCA/INIT: summary
Message-Id: <11594.1125541909@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050830050414.7997.92549.sendpatchset@kao2.melbourne.sgi.com>
In-Reply-To: <20050830050414.7997.92549.sendpatchset@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 31 Aug 2005 06:20:53 -0500, 
Robin Holt <holt@sgi.com> wrote:
>How are these different from the set you sent on 8/17?  I tested those
>and they seemed to work for everything I threw at them.

The interrupt registers are now saved across MCA/INIT.  The previous
patches would sometimes get an illegal operation fault after resuming
from INIT because cr.i* had been changed by INIT.

The rendezvous algorithm for INIT master/slave and MCA interrupt has
been changed.  All slaves wait for the master to arrive.  MCA master
pops the slaves out of SAL rendezvous so the slaves end up spinning in
OS state, which means that they can be traced.  The master cpu leaves
MCA/INIT first, then the slaves follow.  The INIT slaves resume to the
previous state in a single threaded sequence, I saw some problems that
implied a race in multiple cpus resuming from INIT at the same time.  I
may remove that single threading later.

Busy loops were changed to use cpu_relax().

