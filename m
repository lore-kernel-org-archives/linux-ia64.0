From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 17 Mar 2008 09:59:13 +0000
Subject: Re: [PATCH] arch/ia64/kernel/: Use time_* macros
Message-Id: <20080317185712.7B4A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1205746593-24820-1-git-send-email-caglar@pardus.org.tr> <1205746593-24820-2-git-send-email-caglar@pardus.org.tr>
In-Reply-To: <1205746593-24820-2-git-send-email-caglar@pardus.org.tr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "S.Ca?lar Onur" <caglar@pardus.org.tr>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

Hi

nice clean up.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> The functions time_before, time_before_eq, time_after, and time_after_eq are more robust for comparing jiffies against other values.
> 
> So following patch implements usage of the time_after() & time_before() macros, defined at linux/jiffies.h, which deals with wrapping correctly




