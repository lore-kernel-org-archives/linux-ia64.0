From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Mon, 18 Feb 2008 13:32:10 +0000
Subject: RSE Behavior on Interruptions
Message-Id: <47B988DA.3020807@bull.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Let's assume a user program just has been interrupted.
The RSE can continue spilling/filling registers on behalf of the interrupted user.
Let's assume the RSE engine touches a swapped out page.
As PSR.ic is 0, the page fault cannot be captured correctly.

Can this scenario happen to the current Linux kernel implementation?

Thanks,

Zoltan Menyhart

