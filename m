From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Jul 2004 15:59:06 +0000
Subject: RE: strict rejection of init -> core references causes problems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F019FB4B2@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>The recent patch of yours to the kernel module loader is causing some
>problems with the netfilter modules.  To recap, with that patch
>applied, calls from the core section of a module to an init section
>are rejected because that's in general a dangerous thing to do (the
>called code may be gone by the time the call gets executed).

I was worried that this might be the case.  I did try loading a
selection of stuff as modules, and didn't hit the problem, but
I obviously didn't have netfilter configured as a module.

I'll make a patch to re-allow this later today.

-Tony
