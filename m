From: Keith Owens <kaos@sgi.com>
Date: Thu, 08 Sep 2005 23:08:34 +0000
Subject: Re: [PATCH 2.6.13 8/7] MCA/INIT: tweaks
Message-Id: <19085.1126220914@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <10631.1126162398@kao2.melbourne.sgi.com>
In-Reply-To: <10631.1126162398@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 8 Sep 2005 13:35:10 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>Keith Owens <kaos@sgi.com> wrote:
>>>This code is definitely ready for inclusion in 2.6.13-rc1.
>>
>>Of course that should be 2.6.14-rc1.
>
>I'm happy that the ia64 parts show a definite improvement on the
>buggy-SAL systems that I can test on.  I'll take your word that
>this runs fine on SN2.  The cleanups to minstate.h alone make this
>patch beautiful in my eyes :-)
>
>We need to go to linux-kernel to get some blessings for the
>changes to <linux/sched.h> and kernel/sched.c.  The very first
>question is likely to be: "Why are curr_task() and set_curr_task()
>exported?" They are only used in mca.c ... which can't be built
>as a module.

Tools like kgdb, kprobes and kdb need curr_task() to check if a task is
running on a cpu or not, those components can be modular.
set_curr_task() does not need to be exported, it is a hang over from
some early testing.  I'll respin the tweaks patch (number 8) to remove
the export of set_curr_task().

