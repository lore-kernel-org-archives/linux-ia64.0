From: Tony Luck <tony.luck@intel.com>
Date: Wed, 06 Jul 2011 21:14:58 +0000
Subject: Re: ia64: replace old cpumask functions with new one
Message-Id: <CA+8MBbLg4jBmaYkVW13WReNm8nyP1p0k3CPN=pQmvwPfRKyeQA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4E031B97.2010609@jp.fujitsu.com>
In-Reply-To: <4E031B97.2010609@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

2011/6/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> We plan to remove old obsolete cpumask functions and plan to
> change task->cpus_allowed implementation in future.
...
> =A0arch/ia64/kernel/smpboot.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 56 +++++++=
++++++++---------------

I get some new warnings in this file with your patch:


arch/ia64/kernel/smpboot.c:454: warning: passing argument 2 of
=91cpumask_set_cpu=92 discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:581: warning: passing argument 1 of
=91cpumask_clear=92 discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:613: warning: passing argument 2 of
=91cpumask_set_cpu=92 discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:637: warning: passing argument 2 of
=91cpumask_set_cpu=92 discards qualifiers from pointer target type
arch/ia64/kernel/smpboot.c:745: warning: passing argument 2 of
=91cpumask_clear_cpu=92 discards qualifiers from pointer target type

Four of the five involve "cpu_callin_mask" which is "volatile", the other i=
s for
"cpu_present_mask" - not sure what the problem is for this one.

-Tony
