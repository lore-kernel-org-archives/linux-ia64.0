From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 19 Nov 2004 06:35:25 +0000
Subject: RE: [PATCH] 2.6.10-rc1 pfmon broken by bad merge?
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F026C5935@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041118230118.GC15892@esmail.cup.hp.com>
In-Reply-To: <20041118230118.GC15892@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Just pulled/rebuilt from the bk linux-ia64-release-2.6.10 tree
>and it failed to build with :
>arch/ia64/kernel/perfmon.c: In function `pfm_handle_work':
>arch/ia64/kernel/perfmon.c:5068: error: parse error before '/' token
>
>Following trivial patch fixes what looks like a merge bug.
>
>Signed-off-by: Grant Grundler <iod00d@hp.com>

Applied.

-Tony
