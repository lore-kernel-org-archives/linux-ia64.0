From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Sep 2005 20:35:10 +0000
Subject: RE: [PATCH 2.6.13 8/7] MCA/INIT: tweaks
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0456ED7E@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10631.1126162398@kao2.melbourne.sgi.com>
In-Reply-To: <10631.1126162398@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens <kaos@sgi.com> wrote:
>>This code is definitely ready for inclusion in 2.6.13-rc1.
>
>Of course that should be 2.6.14-rc1.

I'm happy that the ia64 parts show a definite improvement on the
buggy-SAL systems that I can test on.  I'll take your word that
this runs fine on SN2.  The cleanups to minstate.h alone make this
patch beautiful in my eyes :-)

We need to go to linux-kernel to get some blessings for the
changes to <linux/sched.h> and kernel/sched.c.  The very first
question is likely to be: "Why are curr_task() and set_curr_task()
exported?" They are only used in mca.c ... which can't be built
as a module.

-Tony
