From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 10 Jun 2004 05:28:31 +0000
Subject: RE: [PATCH] Kernel panic on IA-64 Linux with SELinux
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F016C4808@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
In-Reply-To: <013f01c44ddb$636d4aa0$f97d220a@linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>"current" already contains the region 7 address.  Perhaps I'm 
>misunderstanding what you're saying, though.

No, you aren't misunderstanding ... I'd just forgotten that
head.S converted from region 5 to region 7 before initializing
r13 (a.k.a. current).

I'll think about it more when I'm awake.

-Tony
