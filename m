From: "Lynch, Rusty" <rusty.lynch@intel.com>
Date: Tue, 21 Jun 2005 22:03:51 +0000
Subject: scheduler cache-hot-auto-tune patch breaks ia64 UP build
Message-Id: <032EB457B9DBC540BFB1B7B519C78B0E076E3C6A@orsmsx404.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Attempting to build 2.6.12-mm1 on ia64 with CONFIG_SMP disabled will
cause the build to break because max_cache_size is undefined.  I haven't
spent the time to understand the cache-hot-auto-tune feature, so I don't
have a patch to fix the problem.

    --rusty
