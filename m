From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 20 Dec 2003 16:36:28 +0000
Subject: Re: [RFC][PATCH] 2.6.0-test11 sched_clock() broken for "drifty ITC"
Message-Id: <marc-linux-ia64-107193824828407@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107178053026093@msgid-missing>
In-Reply-To: <marc-linux-ia64-107178053026093@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


* Nick Piggin <piggin@cyberone.com.au> wrote:

> I'm just thinking that computers with unsynched clocks have less need
> for good interactivity, but thats probably too narrow and x86 a view
> anyway.

it's also a matter of predictable behavior. The scheduler should not
behave differently just because there's no synchronized clock. 
Behavioral forks like that tend to come back and cause trouble later.

	Ingo
