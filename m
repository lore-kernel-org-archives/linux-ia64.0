From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 17 Aug 2007 18:40:03 +0000
Subject: Re: [PATCH]forbid ptrace changes psr.ri to 3
Message-Id: <200708171240.03836.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
In-Reply-To: <1187244999.30462.6.camel@sli10-conroe.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 17 August 2007 11:21:14 am Luck, Tony wrote:
> > IA64_PSR_RI is in IPSR_MASK, apparently by intent.  
> > If you want to change the behavior, you should simply change that mask.
> 
> psr.ri is more complex because it is two bits where not all of the
> possible bit settings are defined. We definitely want to allow ptrace
> to set psr.ri (how else can we single step through instructions in
> a bundle?)  But we should only allow psr.ri to be set to 0, 1, or 2.

This confused me, too, because the changelog and comments say
"PSR.ri bits 3 are reserved" and "psr.ri bits 11 are reserved".

Something like "PSR.ri value 3 is reserved" would have made
the intent more clear.

Bjorn
