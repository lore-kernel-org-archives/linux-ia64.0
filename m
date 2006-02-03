From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 03 Feb 2006 18:04:06 +0000
Subject: RE: ia64 printk_clock()
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F059C0FC6@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Why don't we look at ar.k3, it contains per_cpu base address.
> If it has a none zero value, then it is initialized by
> per_cpu_init and is safe to call sched_clock.

Looks good to me[1].

-Tony

[1] http://tinyurl.com/ah642
