From: Nishanth Aravamudan <nacc@us.ibm.com>
Date: Wed, 01 Aug 2007 02:39:54 +0000
Subject: Re: "Add support for vector domain" breaks boot on x355
Message-Id: <20070801023954.GE31324@us.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731221356.GA31324@us.ibm.com> <1185932623.3920.5.camel@kane-linux>
In-Reply-To: <1185932623.3920.5.camel@kane-linux>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: isimatu.yasuaki@jp.fujitsu.com, tony.luck@intel.com, torvalds@linux-foundation.org, ryhodges@us.ibm.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 01.08.2007 [10:43:43 +0900], Kenji Kaneshige wrote:
> 2007-07-31 (?$B2P) ?$B$N 15:13 -0700 ?$B$K Nishanth Aravamudan ?$B$5$s$O=q$-$^$7$?:
> > The following commit (4994be1b3fe9120c88022ff5c0c33f6312b17adb) broke
> > Linus' Tree between 2.6.22-git15 and 2.6.22-git16 on a 2-node 8-way x455
> > (Madison procs). Thanks to Ryan Hodges for bisecting down to this
> > commit.
> 
> Thank you for reporting.
> 
> I think this problem might be fixed by the commit
> 6ffbc82351c62eeeeaeb9e817ddf93049353493d. Could you try that?

Ah you might be right. Our testing harness is missing that the kernel
came up further, at least. (2.6.23-rc1-git9 works fine, mostly, it looks
like)

Thanks!
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
