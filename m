From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 25 Feb 2008 03:16:42 +0000
Subject: [PATCH 0/4] ia64/xen: paravirtualization of hand written assembly code
Message-Id: <12039094061834-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi. The patch I send before was too large so that it was dropped from
the maling list. I'm sending again with smaller size.
This patch set is the xen paravirtualization of hand written assenbly
code. And I expect that much clean up is necessary before merge.
We really need the feed back before starting actual clean up as Eddie
already said before.

Eddie discussed how to clean up and suggested several ways.
  1: Dual IVT source code, dual IVT table. (The way this patch set adopted)
  2: Same IVT source code, but dual/mulitple compile to generate
     dual/multiple IVT table using assembler macro.
  3: Single IVT table, using indirect function call for pv_ops using
     branch/binary patching.

At this moment my preference is the option 2. Please comment.

thanks,
