From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 Oct 2007 23:38:32 +0000
Subject: RE: [PATCH] ptrace RSE bug
Message-Id: <617E1C2C70743745A92448908E030B2A02C64D86@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1188357710.22637.7.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Thanks. So Tony, how do think about the IA64 part of the patch?

Having to use ia64_peek() and ia64_poke() to copy the RBS 8 bytes
at a time looks a bit ugly ... but this isn't in the performance
path (unless you are running your whole application under strace(1)!)
so it probably isn't an issue.  If it turns out to be, then an
incremental fix on top of this would be the way to go.

So I'm ok with the ia64 parts ... which leaves the open issue
of the generic part (moving the spin_unlock_irq() after the
set_current_state(TASK_TRACED)) ... which (if I follow this
thread correctly) is still an open issue, right?

-Tony
