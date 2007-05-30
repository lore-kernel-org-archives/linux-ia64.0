From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Wed, 30 May 2007 23:56:47 +0000
Subject: RE: BUG: sleeping function called from invalid context at kernel/fork.c:385
Message-Id: <79E93560F4A5FD42BB769DAAF8BEF62A01B633E9@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <f1318b470705301650y5ed9fdbn12ad0ebe30233336@mail.gmail.com>
References: <20070522234314.54081817.akpm@linux-foundation.org>
In-Reply-To: <20070522234314.54081817.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, David Chinner <dgc@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>, Christoph Lameter <clameter@sgi.com>

> Saw this when running strace -f on a script on 2.6.21 on ia64
Run strace -f on 2.6.22-rc3 on Tiger4/Montecito. Couldn't reproduce
this issue. Kernel was built with both defconfig and tiger_defconfig.

Thanks.

-Fenghua
