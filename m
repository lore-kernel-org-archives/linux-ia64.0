From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Mon, 02 May 2022 07:58:19 +0000
Subject: Re: [PATCH v2 02/12] signal: Replace __group_send_sig_info with send_signal_locked
Message-Id: <Ym+PG/5Ro/v3nJUR@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <87k0b7v9yk.fsf_-_@email.froward.int.ebiederm.org>
 <20220429214837.386518-2-ebiederm@xmission.com>
In-Reply-To: <20220429214837.386518-2-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, rjw@rjwysocki.net, Oleg Nesterov <oleg@redhat.com>, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Kees Cook <keescook@chromium.org>, Jann Horn <jannh@google.com>, linux-ia64@vger.kernel.org

On 2022-04-29 16:48:27 [-0500], Eric W. Biederman wrote:
> The function send_signal_locked does more than __group_send_sig_info so
> replace it.

This might be easier to understand:
   __group_send_sig_info() is just a wrapper around send_signal_locked()
   with a special pid_type. 
   
   Replace __group_send_sig_info() with send_signal_locked(,,,
   PIDTYPE_TGID).

However, keep it as is if you feel otherwise ;)

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Sebastian
