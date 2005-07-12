From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 12 Jul 2005 00:22:36 +0000
Subject: RE: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <200507120022.j6C0Mcg26016@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

KAMEZAWA Hiroyuki wrote on Monday, July 11, 2005 5:14 PM
> By the way, can ia64's copy_to_user(from, buf, size) catch bad "from" ?

Yes, it has exception handler for both source and destination address.

