From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Wed, 12 Feb 2003 23:29:49 +0000
Subject: [Linux-ia64] Preemption patch
Message-Id: <marc-linux-ia64-105590709805838@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David,
   Turned out that the problems I was having with the preemption patch
were indeed hardware related.  So feel free to merge that patch.
There're still problems with Perfmon, but I'd rather wait until
Stephane's new code is merged before addressing them.

I've run withpreemption enabled on dual and single McKinley  and on
the simualtor and so far so good.  I see interrupt latency variablilty
drop from 4000--320000 cycles to 4000--8000 cycles, which is good.
I don't yet see any major user-visible differences though.

Peter C


