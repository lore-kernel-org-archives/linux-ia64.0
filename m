From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 12 Jul 2011 08:27:08 +0000
Subject: Re: ia64: replace old cpumask functions with new one
Message-Id: <4E1C055C.1030103@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4E031B97.2010609@jp.fujitsu.com> <CA+8MBbLg4jBmaYkVW13WReNm8nyP1p0k3CPN=pQmvwPfRKyeQA@mail.gmail.com>
In-Reply-To: <CA+8MBbLg4jBmaYkVW13WReNm8nyP1p0k3CPN=pQmvwPfRKyeQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

(2011/07/07 6:14), Tony Luck wrote:
> 2011/6/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
>> We plan to remove old obsolete cpumask functions and plan to
>> change task->cpus_allowed implementation in future.
> ...
>>  arch/ia64/kernel/smpboot.c              |   56 +++++++++++++++---------=
------
>=20
> I get some new warnings in this file with your patch:
>=20
>=20
> arch/ia64/kernel/smpboot.c:454: warning: passing argument 2 of
> =91cpumask_set_cpu=92 discards qualifiers from pointer target type
> arch/ia64/kernel/smpboot.c:581: warning: passing argument 1 of
> =91cpumask_clear=92 discards qualifiers from pointer target type
> arch/ia64/kernel/smpboot.c:613: warning: passing argument 2 of
> =91cpumask_set_cpu=92 discards qualifiers from pointer target type
> arch/ia64/kernel/smpboot.c:637: warning: passing argument 2 of
> =91cpumask_set_cpu=92 discards qualifiers from pointer target type
> arch/ia64/kernel/smpboot.c:745: warning: passing argument 2 of
> =91cpumask_clear_cpu=92 discards qualifiers from pointer target type
>=20
> Four of the five involve "cpu_callin_mask" which is "volatile", the other=
 is for
> "cpu_present_mask" - not sure what the problem is for this one.

Sorry for the delay. I'm sorry for the annoying you.
But ummm.. I can't understand the author expect which effect by this volati=
le.
If I am correct, its volatile has no effect. we can simply remove it.

So, I'll respin this.

Thanks.


