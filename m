From: Chris Wedgwood <cw@f00f.org>
Date: Fri, 26 Mar 2004 23:41:10 +0000
Subject: Re: should ia64_spinlock_contention do backoff?
Message-Id: <20040326234110.GA27824@dingdong.cryptoapps.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
In-Reply-To: <200403251941.i2PJfrTH026392@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 26, 2004 at 09:16:52AM -0800, markw@osdl.org wrote:

> We have 4-way Itanium2 systems here.  Is that large enough for
> testing?

It depends on the level of lock contention and what the remote memory
latency is (well, essentially how quickly you can bounce cachelines
about).  As other people have mentioned SGI has tested this on much
larger configurations without seeing much incentive to use it.

As a general principal I think getting lock contention down is more
worthwhile (but very much harder usually).

Does anyone have any idea what locks are most heavily contented for
ia64 right now?  John?


  --cw
