From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 09 Dec 2004 23:19:07 +0000
Subject: RE: [patch 2.6.10-rc3] Add TIF_SIGDELAYED processing
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F028826C8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <15449.1102482344@kao1.melbourne.sgi.com>
In-Reply-To: <15449.1102482344@kao1.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I just think stashing away pids in the kernel is a slippery slope we
>do not want to get onto.
>
>Can't you stash away a reference to the task-structure and bump the
>reference count?

Can we do that in MCA context (without getting any locks)?

-Tony
