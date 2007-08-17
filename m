From: Roland McGrath <roland@redhat.com>
Date: Fri, 17 Aug 2007 06:01:21 +0000
Subject: Re: [PATCH]forbid ptrace changes psr.ri to 3
Message-Id: <20070817060121.687DD4D057D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

IA64_PSR_RI is in IPSR_MASK, apparently by intent.  
If you want to change the behavior, you should simply change that mask.


Thanks,
Roland
