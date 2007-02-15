From: "Akinobu Mita" <akinobu.mita@gmail.com>
Date: Thu, 15 Feb 2007 12:44:34 +0000
Subject: Re: fault-injection framework on ia64
Message-Id: <961aa3350702150444x51a9ceefga37121c2ba97f356@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
In-Reply-To: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2007/2/15, Andrew Morton <akpm@linux-foundation.org>:
>
> lib/built-in.o(.text+0x2c192): In function `should_fail':
> : undefined reference to `save_stack_trace'
>
> We could disable the feature on ia64, but then they wouldn't be able to
> inject faults.

I couldn't understand this build error happend.
(I might misunderstand something)
Because IA64 config always disable CONFIG_STACKTRACE, so
should_fail() doesn't use save_stack_trace() in fail_stacktrace().
