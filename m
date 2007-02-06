From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Tue, 06 Feb 2007 21:32:02 +0000
Subject: RE: [PATCH] Hook up getcpu system call for IA64
Message-Id: <A29F7A5700A7EA4380E08C1F68C3B6D80219F472@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206000757.GA32026@linux-os.sc.intel.com>
In-Reply-To: <20070206000757.GA32026@linux-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


>I know it's trivial to wire up sys_getcpu, but please take this
seriously,
>it should be implemented as assembly fsys call.

Ken,

Could you please explain why fsys call? Sys_getcpu takes about 600cycles
on 1.6GHz Montecito. Do we need to save these cycles?

Thanks.

-Fenghua
