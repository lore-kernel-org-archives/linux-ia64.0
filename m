From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 18 Mar 2011 12:21:44 +0000
Subject: Re: [PATCH 10/36] ia64,rcu: convert call_rcu(sn_irq_info_free) to
Message-Id: <20110318122144.GH14675@home.goodmis.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4D82D7AD.2060205@cn.fujitsu.com>
In-Reply-To: <4D82D7AD.2060205@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Jes Sorensen <jes@sgi.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Tejun Heo <tj@kernel.org>, linux-altix@sgi.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Lai,

Something weird happened to your patch series. Patches 2-9 were properly
a reply to patch 1, but from this patch forward, each patch was its own
separate thread.

-- Steve

