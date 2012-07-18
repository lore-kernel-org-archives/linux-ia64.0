From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 18 Jul 2012 13:47:28 +0000
Subject: RE: ia64 build errors
Message-Id: <3908561D78D1C84285E8C5FCA982C28F1936D13A@ORSMSX104.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20120717123233.GA17001@localhost>
In-Reply-To: <20120717123233.GA17001@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Anyway, let's focus on the regular configs for now: when removing the
> randconfig tests, only the IA64_TASK_SIZE error remains in allmodconfig.

Ok - I'll look into and fix that one (I feel especially motivated since I put in
the patch to drop variable  TASKSIZE recently ... so it's highly likely that this
break is my fault :-)

-Tony
