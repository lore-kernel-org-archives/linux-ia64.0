From: Dean Nelson <dcn@sgi.com>
Date: Mon, 11 Jul 2005 12:52:56 +0000
Subject: Re: [PATCH 6/14] ia64/sn: use msleep_interruptible() instead of schedule_timeout()
Message-Id: <20050711125256.GA26049@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050709001022.GL2596@us.ibm.com>
In-Reply-To: <20050709001022.GL2596@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org

On Fri, Jul 08, 2005 at 05:10:22PM -0700, Nishanth Aravamudan wrote:
> From: Nishanth Aravamudan <nacc@us.ibm.com>
> 
> Description: Replace schedule_timeout() with msleep_interruptible() to
> guarantee the task delays as expected.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Your changes to arch/ia64/sn/kernel/xpc_main.c looked good to me. Thanks.

