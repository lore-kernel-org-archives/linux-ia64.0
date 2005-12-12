From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 12 Dec 2005 02:34:18 +0000
Subject: RE: [patch 2.6.15-rc5] Define an ia64 version of __raw_read_trylock
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F052E0D4D@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17916.1134185068@ocs3.ocs.com.au>
In-Reply-To: <17916.1134185068@ocs3.ocs.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>IA64 is using the generic version of __raw_read_trylock, which always
>waits for the lock to be free instead of returning when the lock is in
>use.

That sounds like a bug in the generic code.  A locking function
with "try" in its name has some pretty obvious semantics!

-Tony
