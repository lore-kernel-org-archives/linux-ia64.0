From: david mosberger <dmosberger@gmail.com>
Date: Fri, 08 Jul 2005 04:37:15 +0000
Subject: Re: [PATCH 2.6.13-rc1 07/10] IOCHK interface for I/O error handling/detecting
Message-Id: <ed5aea4305070721373480591d@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com> <42CB6961.2060508@jp.fujitsu.com>
In-Reply-To: <42CB6961.2060508@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On 7/5/05, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> wrote:

>    - could anyone write same barrier for intel compiler?
>      Tony or David, could you help me?

I think it might be best to make ia64_mca_barrier() a proper
subroutine written in assembly code.  Yes, that costs some time, but
we're talking about wasting 1,000+ cycles just to consume the value
read via readX(), so the call-overhead is actually overlapped and
completely trivial.

  --david
