From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Wed, 01 Aug 2007 01:43:43 +0000
Subject: Re: "Add support for vector domain" breaks boot on x355
Message-Id: <1185932623.3920.5.camel@kane-linux>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070731221356.GA31324@us.ibm.com>
In-Reply-To: <20070731221356.GA31324@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: isimatu.yasuaki@jp.fujitsu.com, tony.luck@intel.com, torvalds@linux-foundation.org, ryhodges@us.ibm.com, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

2007-07-31 (火) の 15:13 -0700 に Nishanth Aravamudan さんは書きました:
> The following commit (4994be1b3fe9120c88022ff5c0c33f6312b17adb) broke
> Linus' Tree between 2.6.22-git15 and 2.6.22-git16 on a 2-node 8-way x455
> (Madison procs). Thanks to Ryan Hodges for bisecting down to this
> commit.

Thank you for reporting.

I think this problem might be fixed by the commit
6ffbc82351c62eeeeaeb9e817ddf93049353493d. Could you try that?

Thanks,
Kenji Kaneshige


