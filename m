From: Andi Kleen <ak@muc.de>
Date: Thu, 08 Apr 2004 17:51:26 +0000
Subject: Re: HUGETLB commit handling.
Message-Id: <20040408175126.GA72736@colin2.muc.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1IKJu-Zn-29@gated-at.bofh.it> <m3u0zuwgbf.fsf@averell.firstfloor.org> <40758A74.3040107@sgi.com>
In-Reply-To: <40758A74.3040107@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: Andi Kleen <ak@muc.de>, Andy Whitcroft <apw@shadowen.org>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, anton@samba.org, sds@epoch.ncsc.mil, ak@suse.de, lse-tech@lists.sourceforge.net, linux-ia64@vger.kernel.org

> The other problem we are wrestling with is how to do the ia386 and ia64 
> lazy allocation code without breaking the architectures that haven't yet 
> switched to lazy allocation.  There will probbaly be some
> 
> #define ARCH_USES_HUGETLB_PREFAULT
> 
> nonsense added to deal with the latter, if needed.

In my patch I just used weak functions: use a dummy weak function
in the high level code and overwrite from the architecture specific 
code as needed. This avoids all the ifdefs.

-Andi
