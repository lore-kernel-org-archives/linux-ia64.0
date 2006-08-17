From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 17 Aug 2006 13:58:45 +0000
Subject: Re: [patch 3/5] git-ia64 versus genirq
Message-Id: <m18xlnzcoa.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060817071455.164893000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Horms <horms@verge.net.au> writes:

> On Thu, 17 Aug 2006 00:28:53 -0700, Andrew Morton wrote:
>> On Thu, 17 Aug 2006 16:07:22 +0900
>> horms@tabatha.lab.ultramonkey.org wrote:
>> 
>>> > commit 1f4c5c1fe2a6a74271989ec079af11e2bb8e2826
>>> > tree a0da63a3dcc3ffd71653ecc039db416dbcaa86d4
>>> > parent beada884dd437b509c26b39f1a0b0c6b31e6f340
>>> > author Andrew Morton <akpm@osdl.org> 1151573360 -0700
>>> > committer Tony Luck <tony.luck@intel.com> 1151607053 -0700
>>> > 
>>> > [IA64] git-ia64 versus genirq
>>> > 
>>> > Fix the git-ia64 tree after genirq merge.
>>> > 
>>> > Signed-off-by: Andrew Morton <akpm@osdl.org>
>>> > Signed-off-by: Tony Luck <tony.luck@intel.com>
>>> 
>>> Patch from test branch of Tony Luck's ia64 tree.
>>> This is needed for ia64 kexec in Linus's tree.
>>> 
>> 
>> I think you're telling us that Tony needs to get this into mainline, yes?
>
> This would be ia64 kexec.
>
> I was thinking more along the lines that it would be nice if Zou Nan hai
> sent incremental patches against Tony's tree. But he probably gets more
> testing by sending out a apply and forget patch against 2.6.18-rc4. And
> certainly merging ia64 kexec into Linus' tree would be a nice resolution
> to this problem.
>
> At OLS Tony spoke about what state he would like to see kexec in before
> it is merged into Linus' tree. Basically reports that it works on
> at least a cople of different vendor's gear. That is proving harder
> than one might have hoped. But the code is marked as experimental,
> and if pushing it into Linus's tree both makes patch management a bit
> easier, and potentially gives the code better testing, then it seems
> like a good idea to me.

Guys I have a serious problem with this patchset.

It does way to much crap on the crash shutdown path, and none of the
improvements we discussed making at OLS have even been touched.  Even
from Zou Nan hai patchset there was a comment we should use the
startup IPI but he didn't because the firmware implements improperly.

We had a presentation at OLS about how on x86 where we have a fairly minimal
crash_shutdown how that implementation suffers from being nowhere near
paranoid enough.  With this patchset I can almost guarantee your kexec
on panic path is worthless in the face of real failures.

Tony's point on testing is also important, but this is the kind of
code path you can only get right by being paranoid and reviewing the
code carefully.

There is way to much of this patchset where it appears you are
trying to solve things on the shutdown path and not in the init
routines.  We had several discussions at OLS where it was the
indisputed conclusion that there were no short cuts.  Fixing things
right in the init routines was the way to go.

Things like the genirq have no place even affecting the kexec on
panic path.

Do I need to get specific and describe the faults of each individual
function or have I said enough?

Eric
