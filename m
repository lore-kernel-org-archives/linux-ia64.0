From: Jes Sorensen <jes@sgi.com>
Date: Tue, 01 Apr 2008 08:34:57 +0000
Subject: Re: [02/17][PATCH] Implement smp_call_function_mask for ia64 - V8
Message-Id: <47F1F3B1.7020308@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42DFA526FC41B1429CE7279EF83C6BDC01048240@pdsmsx415.ccr.corp.intel.com> <47F0AB18.2010707@sgi.com> <47F0FCFE.5010106@goop.org>
In-Reply-To: <47F0FCFE.5010106@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: "Zhang, Xiantao" <xiantao.zhang@intel.com>, Carsten Otte <cotte@de.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, linux-ia64@vger.kernel.org, kvm-ia64-devel@lists.sourceforge.net, kvm-devel@lists.sourceforge.net, virtualization@lists.linux-foundation.org, "Xu, Anthony" <anthony.xu@intel.com>

Jeremy Fitzhardinge wrote:
> Jes Sorensen wrote:
> This change has been on the x86 side for ages, and not even Ingo made a 
> peep about it ;)

Mmmm, last time I looked, x86 didn't scale to any interesting number
of CPUs :-)

>> Why not keep smp_call_function() the way it was before, rather than
>> implementing it via the call to smp_call_function_mask()?
> 
> Because Xen needs a different core implementation (because of its 
> different IPI implementation), and it would be better to just have to do 
> one of them rather than N.

I wasn't suggesting we shouldn't have both interfaces, merely
questioning why adding what to me seems like an unnecessary performance
hit for the classic case of the call.

Cheers,
Jes
