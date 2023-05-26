From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 26 May 2023 05:35:34 +0000
Subject: Re: [PATCH v2 2/3] compiler: inline does not imply notrace
Message-Id: <20230526013534.76e5b613@rorschach.local.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230525210040.3637-1-namit@vmware.com>
        <20230525210040.3637-3-namit@vmware.com>
        <20230525222844.6a0d84f8@rorschach.local.home>
        <D4B1FB24-C351-411B-8A40-4DAFE95FA921@gmail.com>
In-Reply-To: <D4B1FB24-C351-411B-8A40-4DAFE95FA921@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-um@lists.infradead.org, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Borislav Petkov <bp@alien8.de>, X86 ML <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Thu, 25 May 2023 22:17:33 -0700
Nadav Amit <nadav.amit@gmail.com> wrote:


> > FYI, I have a patch queued (still needs to go through testing) that
> > already does this ;-)
> > 
> > https://lore.kernel.org/all/20230502164102.1a51cdb4@gandalf.local.home/  
> 
> Ugh. If you cc’d me, I wouldn’t bother you during your vacation. :)

I'm currently passed the vacation part and now in Taiwan for work.

> 
> I think you may like the first patch in my series to precede this patch
> though as some of the function I marked as “notrace" are currently “inline”.
> 
> Let me know how you want to proceed, so I would know how to break this
> series.

Currently there's a nasty bug in v6.4-rc3 I'm fighting where I can't
proceed on anything until it's resolved. But I could also just pull
your first and third patch too. I'll let you know when I'm finished
debugging.

-- Steve
