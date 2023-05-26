From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 26 May 2023 05:40:18 +0000
Subject: Re: [PATCH v2 2/3] compiler: inline does not imply notrace
Message-Id: <20230526014018.5ebafc55@rorschach.local.home>
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

> Ugh. If you cc’d me, I wouldn’t bother you during your vacation. :)

Oh, and if you are interested in tracing patches, just subscribe to
linux-trace-kernel@vger.kernel.org.

-- Steve
