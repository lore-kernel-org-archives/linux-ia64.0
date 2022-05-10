From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 10 May 2022 15:18:32 +0000
Subject: Re: [PATCH v4 0/12] ptrace: cleaning up ptrace_stop
Message-Id: <877d6twh4n.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
        <20220421150654.817117821@infradead.org>
        <87czhap9dy.fsf@email.froward.int.ebiederm.org>
        <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <20220510141119.GA23277@redhat.com>
        <87lev9xy3n.fsf@email.froward.int.ebiederm.org>
        <Ynp6fP8QkIGvUT1T@linutronix.de>
In-Reply-To: <Ynp6fP8QkIGvUT1T@linutronix.de> (Sebastian Andrzej Siewior's
        message of "Tue, 10 May 2022 16:45:16 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org

Sebastian Andrzej Siewior <bigeasy@linutronix.de> writes:

> On 2022-05-10 09:26:36 [-0500], Eric W. Biederman wrote:
>> Does anyone else have any comments on this patchset?
>> 
>> If not I am going to apply this to a branch and get it into linux-next.
>
> Looks good I guess.
> Be aware that there will be clash due to
>    https://lore.kernel.org/all/1649240981-11024-3-git-send-email-yangtiezhu@loongson.cn/
>
> which sits currently in -akpm.

Thanks for the heads up.  That looks like the best kind of conflict.
One where code just disappears.

Eric
