From: Oleg Nesterov <oleg@redhat.com>
Date: Thu, 05 May 2022 17:27:45 +0000
Subject: Re: [PATCH v3 08/11] ptrace: Admit ptrace_stop can generate spuriuos SIGTRAPs
Message-Id: <20220505172744.GA13664@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b0apne.fsf_-_@email.froward.int.ebiederm.org>
 <20220504224058.476193-8-ebiederm@xmission.com>
 <20220505150158.GB13929@redhat.com>
 <87a6bv7v49.fsf@email.froward.int.ebiederm.org>
In-Reply-To: <87a6bv7v49.fsf@email.froward.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, bigeasy@linutronix.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 05/05, Eric W. Biederman wrote:
>
> And yes that WARN_ON_ONCE can trigger on PREEMPT_RT but that is just
> because PREMPT_RT is currently broken with respect to ptrace.  Which
> makes a WARN_ON_ONCE appropriate.

Yes agreed. In this case WARN_ON_ONCE() can help a user to understand
that a failure was caused by the kernel problem which we need to fix
anyway.

Oleg.
