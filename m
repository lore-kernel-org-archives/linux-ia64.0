From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 14 Mar 2005 18:03:38 +0000
Subject: Re: Context switch time regression...
Message-Id: <16949.53754.800576.498498@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16949.4142.908795.242198@wombat.chubb.wattle.id.au>
In-Reply-To: <16949.4142.908795.242198@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 14 Mar 2005 15:16:46 +1100, Peter Chubb <peterc@gelato.unsw.edu.au> said:

  Peter> According to LMbench2 on a 2-way 900MHz Itanium 2:

  Peter> Context switching 0K - times in microseconds - smaller is better
  Peter> ----------------------------------------------------------------
  Peter> OS                               2p/0k      4p/0k      8p/0k
  Peter> ctx swtch  ctx swtch  ctx swtch
  Peter> -----------------------------  ---------  ---------  ---------
  Peter> Linux 2.5.72                   1.5700000  1.6200000  1.7700000
  Peter> Linux 2.6.0                      15.0600  8.6900000  8.8600000
  Peter> Linux 2.6.11                     17.1900    17.2100    10.5400

  Peter> I have to go now, but I'll try to track this down tomorrow.

I have noticed the same a while ago.  Someone from Intel (Ken, IIRC)
investigated and confirmed that it is due to a scheduler change.
Basically, the scheduler is now much more aggressive about
loading-balancing to an idle CPU.  Try running LMbench as "taskset 1
make rerun" and you'll see the effect.  This has resulted in a
discussion with Carl Staelin (co-author and current maintainer of
LMbench) as to how LMbench could control for such issues.  It's not
finished yet, but hopefully a future version of LMbench3 will
(optionally) allow you to control the affinity of processes so you can
factor out scheduling effects if desired.

	--david
