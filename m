From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu, 19 May 2022 06:19:40 +0000
Subject: Re: [PATCH 00/16] ptrace: cleanups and calling do_cldstop with only siglock
Message-Id: <YoXhfGGPKnT/YFC1@linutronix.de>
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
In-Reply-To: <CALWUPBdFDLuT7JaNGSJ_UXbHf8y9uKdC-SkAqzd=FQC0MX4nNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle Huey <khuey@pernos.co>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, LKML <linux-kernel@vger.kernel.org>, rjw@rjwysocki.net, oleg@redhat.com, mingo@kernel.org, vincent.guittot@linaro.org, dietmar.eggemann@arm.com, rostedt@goodmis.org, mgorman@suse.de, Will Deacon <will@kernel.org>, tj@kernel.org, linux-pm@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, linux-um@lists.infradead.org, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, linux-xtensa@linux-xtensa.org, Jann Horn <jannh@google.com>, Kees Cook <keescook@chromium.org>, linux-ia64@vger.kernel.org, Robert O'Callahan <roc@pernos.co>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Jason Wessel <jason.wessel@windriver.com>, Daniel Thompson <daniel.thompson@linaro.org>, Douglas Anderson <dianders@chromium.org>, Douglas Miller <dougmill@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>

On 2022-05-18 20:26:05 [-0700], Kyle Huey wrote:
> Is there a git branch somewhere I can pull to test this? It doesn't apply
> cleanly to Linus's tip.

https://kernel.googlesource.com/pub/scm/linux/kernel/git/ebiederm/user-namespace.git ptrace_stop-cleanup-for-v5.19

> - Kyle

Sebastian
