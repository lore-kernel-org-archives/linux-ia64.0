From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 27 Sep 2004 22:51:59 +0000
Subject: Re: CPU utilization measurement tools/methods for network performance tests
Message-Id: <16728.39311.361436.774923@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040927162418.GA2524@fc.hp.com>
In-Reply-To: <20040927162418.GA2524@fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Alex" = Alex Tsariounov <alext@fc.hp.com> writes:

Alex> Hello: I am currently using netperf to measure performance of a
Alex> couple of network drivers on ia64/2.6.7 and am having a trying
Alex> time measuring CPU utilization.

I suggest you check out ipbench (http://ipbench.sf.net) which in its
latency measurement has an accurate CPU-usage measurement algorithm,
at least for uniprocessors.  Because so much network handling happens
at interrupt time, the usual system and user times are useless for
this purpose.

There's going to be a new release of ipbench sometime soon now, a
complete rewrite using Python to drive the system, that should be a
lot more stabole and usable than the current version.



-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
