From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 09 Jul 2004 19:19:46 +0000
Subject: RE: [netfilter-core] strict rejection of init -> core references causes problems
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F019FB697@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>So what really happens is: calls from init to 'core' functions 
>and calls from 'exit' to core functions.

Hmmm.  Neither of those should have tripped the check in the
kernel module loader.  It should only go bang when you have a
call from "core" to "init".  Does "exit" end up in a separate
section?  Maybe I was mistakenly triggering on the exit->core?

Which module actually failed to load?

-Tony
