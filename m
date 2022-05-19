From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Thu, 19 May 2022 18:05:32 +0000
Subject: Re: [PATCH 00/16] ptrace: cleanups and calling do_cldstop with only siglock
Message-Id: <8735h54cur.fsf@email.froward.int.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220421150248.667412396@infradead.org>
        <20220421150654.817117821@infradead.org>
        <87czhap9dy.fsf@email.froward.int.ebiederm.org>
        <878rrrh32q.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
        <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
        <87a6bv6dl6.fsf_-_@email.froward.int.ebiederm.org>
        <871qwq5ucx.fsf_-_@email.froward.int.ebiederm.org>
        <CALWUPBdFDLuT7JaNGSJ_UXbHf8y9uKdC-SkAqzd=FQC0MX4nNQ@mail.gmail.com>
        <YoXhfGGPKnT/YFC1@linutronix.de>
In-Reply-To: <YoXhfGGPKnT/YFC1@linutronix.de> (Sebastian Andrzej Siewior's
        message of "Thu, 19 May 2022 08:19:40 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Kyle Huey <khuey@pernos.co>, LKML <linux-kernel@vger.kernel.org>, rjw@rjwysocki.net, oleg@redhat.com, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org, Robert O'Callahan <roc@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

Sebastian Andrzej Siewior <bigeasy@linutronix.de> writes:

> On 2022-05-18 20:26:05 [-0700], Kyle Huey wrote:
>> Is there a git branch somewhere I can pull to test this? It doesn't apply
>> cleanly to Linus's tip.
>
> https://kernel.googlesource.com/pub/scm/linux/kernel/git/ebiederm/user-namespace.git ptrace_stop-cleanup-for-v5.19

Yes that is the branch this all applies to.

This is my second round of cleanups this cycle for this code.
I just keep finding little things that deserve to be changed,
when I am working on the more substantial issues.

Eric


