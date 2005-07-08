From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 08 Jul 2005 05:44:49 +0000
Subject: Re: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <42CE12D0.7060601@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB6961.2060508@jp.fujitsu.com> <ed5aea4305070721373480591d@mail.gmail.com>
In-Reply-To: <ed5aea4305070721373480591d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David.Mosberger@acm.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

david mosberger wrote:
>>   - could anyone write same barrier for intel compiler?
>>     Tony or David, could you help me?
> 
> I think it might be best to make ia64_mca_barrier() a proper
> subroutine written in assembly code.  Yes, that costs some time, but
> we're talking about wasting 1,000+ cycles just to consume the value
> read via readX(), so the call-overhead is actually overlapped and
> completely trivial.

Yes, of course speed is worth, but in some situations it can happen
that the data integrity is better than the speed.
(sounds crazy but fact)

I'm not familiar with assembly code for intel compiler. So David,
could you write another macro of ia64_mca_barrier() or a proper
subroutine instead?

Thanks,
H.Seto

