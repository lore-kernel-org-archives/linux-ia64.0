From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 31 Aug 2007 01:45:00 +0000
Subject: RE: [PATCH 1/1] Allow global purge traslation cache (ptc.g) to bedisabled
Message-Id: <617E1C2C70743745A92448908E030B2A024F3216@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708301338.34246.protasnb@gmail.com>
In-Reply-To: <200708301338.34246.protasnb@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Please consider the scenario when many cpus are calling
> ia64_global_tlb_purge at the same time without any lock.
> Using global variables to indicate tlb flush start and end is not safe
> here.	

Isn't everything protected by the

	spin_lock(&ptcg_lock);
	 ...
	spin_unlock(&ptcg_lock);

in ia64_global_tlb_purge()?  Though the comment that this lock
is required for HW serialization would need to be updated to
note that the s/w implementation also requires this serialization.

-Tony
