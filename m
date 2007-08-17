From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Aug 2007 17:21:14 +0000
Subject: RE: [PATCH]forbid ptrace changes psr.ri to 3
Message-Id: <617E1C2C70743745A92448908E030B2A02322862@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> IA64_PSR_RI is in IPSR_MASK, apparently by intent.  
> If you want to change the behavior, you should simply change that mask.

psr.ri is more complex because it is two bits where not all of the
possible bit settings are defined. We definitely want to allow ptrace
to set psr.ri (how else can we single step through instructions in
a bundle?)  But we should only allow psr.ri to be set to 0, 1, or 2.

I don't see how changing IPSR_MASK can help solve this.

-Tony
