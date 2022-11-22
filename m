From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 22 Nov 2022 20:28:05 +0000
Subject: Re: [PATCH 3/3] compiler: inline does not imply notrace
Message-Id: <20221122152805.6d16afc8@gandalf.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221122195329.252654-1-namit@vmware.com>
        <20221122195329.252654-4-namit@vmware.com>
        <de999ab8-78ff-44f7-aacc-68561897c6e2@app.fastmail.com>
In-Reply-To: <de999ab8-78ff-44f7-aacc-68561897c6e2@app.fastmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, Richard Weinberger <richard@nod.at>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Johannes Berg <johannes@sipsolutions.net>, Andrew Morton <akpm@linux-foundation.org>, Nadav Amit <namit@vmware.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, 22 Nov 2022 21:09:08 +0100
"Arnd Bergmann" <arnd@arndb.de> wrote:

> On Tue, Nov 22, 2022, at 20:53, Nadav Amit wrote:
> > From: Nadav Amit <namit@vmware.com>
> >
> > Functions that are marked as "inline" are currently also not tracable.
> > Apparently, this has been done to prevent differences between different
> > configs that caused different functions to be tracable on different
> > platforms.
> >
> > Anyhow, this consideration is not very strong, and tying "inline" and
> > "notrace" does not seem very beneficial. The "inline" keyword is just a
> > hint, and many functions are currently not tracable due to this reason.  
> 
> The original reason was listed in 93b3cca1ccd3 ("ftrace: Make all
> inline tags also include notrace"), which describes
> 
>     Commit 5963e317b1e9d2a ("ftrace/x86: Do not change stacks in DEBUG when
>     calling lockdep") prevented lockdep calls from the int3 breakpoint handler
>     from reseting the stack if a function that was called was in the process
>     of being converted for tracing and had a breakpoint on it. The idea is,
>     before calling the lockdep code, do a load_idt() to the special IDT that
>     kept the breakpoint stack from reseting. This worked well as a quick fix
>     for this kernel release, until a certain config caused a lockup in the
>     function tracer start up tests.
>     
>     Investigating it, I found that the load_idt that was used to prevent
>     the int3 from changing stacks was itself being traced!
> 
> and this sounds like a much stronger reason than what you describe,
> and I would expect your change to cause regressions in similar places.
> 
> It's possible that the right answer is that the affected functions
> should be marked as __always_inline. 

Actually, this requirement may not be as needed as much today. There's been
a lot of work in the last 10 years (when that commit was added) to make
ftrace much more robust.

We could remove the notrace from inline and then see where it breaks ;-)

But I'm guessing that it's probably not as much of an issue as it was
before. Although, it may cause some splats with noinstr but I think that
will be caught at compile time.

-- Steve
