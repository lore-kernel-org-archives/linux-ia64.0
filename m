From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 04 Dec 2003 06:23:05 +0000
Subject: Re: [patch] 2.6.0-test9 pal/sal/salinfo/mca
Message-Id: <marc-linux-ia64-107051940804793@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106978478405713@msgid-missing>
In-Reply-To: <marc-linux-ia64-106978478405713@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Ben,

On Wed, Dec 03, 2003 at 05:38:19PM -0800, Ben Woodard wrote:
> 
> Also if the 2.6 backport is the way to go, would other people be
> interested in having the 2.6 MCA code backport made available? Once we

Yes, it is important to have the full MCA support in RHEL kernel. For
instance, the MCA INIT handler is a very useful piece of code to debug
deadlocks when it is coupled to the kernel stack unwinder (which is 
th default on 2.6). I wish I had this feature today in RHEL-3.0.

-- 
-Stephane
