From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 26 May 2023 02:28:44 +0000
Subject: Re: [PATCH v2 2/3] compiler: inline does not imply notrace
Message-Id: <20230525222844.6a0d84f8@rorschach.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230525210040.3637-1-namit@vmware.com>
        <20230525210040.3637-3-namit@vmware.com>
In-Reply-To: <20230525210040.3637-3-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Nadav Amit <namit@vmware.com>

On Thu, 25 May 2023 14:00:39 -0700
Nadav Amit <nadav.amit@gmail.com> wrote:

> From: Nadav Amit <namit@vmware.com>
> 
> Functions that are marked as "inline" are currently also not tracable.
> This limits tracing functionality for many functions for no reason.
> Apparently, this has been done for two reasons.
> 
> First, as described in commit 5963e317b1e9d2a ("ftrace/x86: Do not
> change stacks in DEBUG when calling lockdep"), it was intended to
> prevent some functions that cannot be traced from being traced as these
> functions were marked as inline (among others).
> 
> Yet, this change has been done a decade ago, and according to Steven
> Rostedt, ftrace should have improved and hopefully resolved nested
> tracing issues by now. Arguably, if functions that should be traced -
> for instance since they are used during tracing - still exist, they
> should be marked as notrace explicitly.
> 
> The second reason, which Steven raised, is that attaching "notrace" to
> "inline" prevented tracing differences between different configs, which
> caused various problem. This consideration is not very strong, and tying
> "inline" and "notrace" does not seem very beneficial. The "inline"
> keyword is just a hint, and many functions are currently not tracable
> due to this reason.
> 
> Disconnect "inline" from "notrace".

FYI, I have a patch queued (still needs to go through testing) that
already does this ;-)

https://lore.kernel.org/all/20230502164102.1a51cdb4@gandalf.local.home/

-- Steve
