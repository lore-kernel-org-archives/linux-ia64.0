From: Vincent Guittot <vincent.guittot@linaro.org>
Date: Tue, 13 May 2014 08:33:14 +0000
Subject: Re: sched: fix: initialization of sched_domain_topology for NUMA
Message-Id: <CAKfTPtDwzFay6oaEYYng59MUfO33hD4WH84Cpz91n=6wRD3y3Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1399929376-4597-1-git-send-email-vincent.guittot@linaro.org> <20140513082609.GA2485@laptop.programming.kicks-ass.net>
In-Reply-To: <20140513082609.GA2485@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@kernel.org>, jet.chen@intel.com, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>

On 13 May 2014 10:26, Peter Zijlstra <peterz@infradead.org> wrote:
> On Mon, May 12, 2014 at 11:16:16PM +0200, Vincent Guittot wrote:
>> sched_domain_topology table is a null terminated array.
>> Add 1 row in the allocation size that will be used as the last row of the
>> table.
>>
>> Reported-by: Jet Chen <jet.chen@intel.com>
>> Tested-by: Jet Chen <jet.chen@intel.com>
>> Signed-off-by: Vincent Guittot <vincent.guittot@linaro.org>
>> link: https://lkml.org/lkml/2014/5/12/130
>>
>> ---
>>
>> Hi Ingo and Peter,
>>
>> This patch fixes the problem that has been reported by Jet Chen
>>
>
> I have no mail from Jet Chen on any recent issues.

Hi Peter,

I have just noticed that you were not in the list of the original message

>
> Also, please describe both the problem and the fix in the Changelog
> without need to refer to secondary sources.

Ok, i'm going to update the commit message with more information

>
> As it stands I've no clue wth this is about.
