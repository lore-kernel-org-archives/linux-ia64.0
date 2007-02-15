From: "Akinobu Mita" <akinobu.mita@gmail.com>
Date: Thu, 15 Feb 2007 13:25:37 +0000
Subject: Re: fault-injection framework on ia64
Message-Id: <961aa3350702150525y74b221c3s9ec1347402f26985@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
In-Reply-To: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> > I couldn't understand this build error happend.
> > (I might misunderstand something)
> > Because IA64 config always disable CONFIG_STACKTRACE, so
> > should_fail() doesn't use save_stack_trace() in fail_stacktrace().
>
> OK.  Maybe this patch broke things:
>
>
> From: "Paolo 'Blaisorblade' Giarrusso" <blaisorblade@yahoo.it>
>
> There is no prompt for STACKTRACE, so it is enabled only when 'select'ed.
> FAULT_INJECTION depends on it, while LOCKDEP selects it.  So
> FAULT_INJECTION becomes visible in Kconfig only when LOCKDEP is enabled.
>

I see. I'll make sub-option for fault injection to enable/disable stacktrace.
It'll fix IA64 build problem and unvisible FAULT_INJECTION without LOCKDEP.
