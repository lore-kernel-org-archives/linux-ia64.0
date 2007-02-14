From: Jay Lan <jlan@sgi.com>
Date: Wed, 14 Feb 2007 02:55:07 +0000
Subject: Re: [Fastboot] [PATCH] [IA64] Point saved_max_pfn to the max_pfn
Message-Id: <45D27A0B.40809@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms wrote:
> On Tue, Feb 13, 2007 at 06:25:34PM +0100, Bernhard Walle wrote:
>> Hello,
>>
>> * Zou Nan hai <nanhai.zou@intel.com> [2007-02-08 05:21]:
>>> 	This is reasonable.
>>> 	So please apply the following patch to make saved_max_pfn point to
>>> max_pfn of entire system.
>> So, as the patch works here also and it's necessary to make kdump
>> working, I suggest including it mainline.
> 
> Agreed, below is a version of the patch for Linus' tree as of this morning.

I have never seen a zero size vmcore at SN before, but the SN platform
is still happy with Nan-hai's patch. :)

- jay

> 

