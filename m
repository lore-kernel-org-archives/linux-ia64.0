From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 12 Jul 2005 01:16:47 +0000
Subject: Re: [PATCH] enable to read region 5 from /dev/kmem
Message-Id: <42D319FF.40604@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42C501CD.4010907@jp.fujitsu.com>
In-Reply-To: <42C501CD.4010907@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Chen, Kenneth W wrote:
> KAMEZAWA Hiroyuki wrote on Monday, July 11, 2005 5:14 PM
> 
>>By the way, can ia64's copy_to_user(from, buf, size) catch bad "from" ?
> 
> 
> Yes, it has exception handler for both source and destination address.
> 

Thank you.

One more question:
Is a user allowd to access region 0-4 from /dev/kmem ? (I thnk it's not allowed)
This patch disables that.

Regards,
Kamezawa Hiroyuki

