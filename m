From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 08 Dec 2004 17:11:32 +0000
Subject: RE: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F028441E3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>+	for (i = 1; i < 3; ++i) {
>+		switch (i) {
>+		case 1: t = find_task_by_pid(pid); break;
>+		case 2: t = current; break;
>+		default: t = idle_task(smp_processor_id()); break;
>+		}

"i" only takes the values "1", "2" in this loop, so we can't
get to the default case.  s/</<=/ ???

-Tony
