From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 13 Jul 2007 23:25:05 +0000
Subject: RE: [RFC][PATCH] fsys_gettimeofday leaps days if it runs with nojitter
Message-Id: <617E1C2C70743745A92448908E030B2A01EA663B@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <468CA2D6.40204@jp.fujitsu.com>
In-Reply-To: <468CA2D6.40204@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Here are 2 pending patches I'm pushing :
>   - [PATCH] ia64: Scalability improvement of gettimeofday with
>             jitter compensation

Bob says his (Pete's) patches will be ready soon (Sunday) so I'll wait
for them to make sure this all fits together cleanly.  This is a definite
2.6.23 candidate.

>   - [PATCH] fsys_gettimeofday leaps days if it runs with nojitter

Applied.

-Tony
