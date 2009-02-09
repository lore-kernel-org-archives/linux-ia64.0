From: Alex Chiang <achiang@hp.com>
Date: Mon, 09 Feb 2009 18:13:38 +0000
Subject: [PATCH v2 0/2] ia64: prevent irq migration race in __cpu_disable
Message-Id: <20090209181338.GD19064@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, stable@kernel.org, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

This is v2 of my attempt to prevent an oops while offlining CPUs.

The change is that the patch becomes a full revert of Paul's
original patch, along with a long changelog that explains the
situation as best as I can determine. It's not 100% satisfactory
to me right now, but the testing we've done supports the patch.

The 2nd patch in the series is mostly cosmetic, and removes a
redundant call to cpu_clear() that we no longer need().

Tony, if you agree with the rationale in 1/2, then this series is
a candidate for .29.

stable team, if Tony pushes upstream for .29, then this series
should be applied to the .27 and .28 stable series.

Thanks.

/ac

