From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 24 Mar 2005 21:36:43 +0000
Subject: RE: syscall improvement patch [0/12]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F03245C83@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
In-Reply-To: <200503240049.j2O0n91k022256@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Baseline (linux-ia64-test-2.6.12):	40	254	232	249
> Reschedule fsys_bubble_down:		38	207	180	206
>
>I'd appreciate if you could check these patches into the
>linux-ia64-test-2.6.12 repository as soon as possible so we can give
>it additional testing-exposure before feeding it into 2.6.13.

Ok ... these changes are in my test-2.6.12 tree.  I'm not seeing any
improvement in the epc path though (running with SLES9 toolchain).

-Tony
