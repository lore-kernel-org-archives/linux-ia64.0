From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 23 Jan 2002 10:34:40 +0000
Subject: Re: [Linux-ia64] Ingo scheduler patch for IA64
Message-Id: <marc-linux-ia64-105590698805917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805913@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805913@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 22 Jan 2002, Erich Focht wrote:

> I hope the task migration interrupt part is ok, I loaded the machine
> quite a bit but /proc/interrupts never showed one occuring.

it only happend during set_cpus_allowed() at the moment.

i plan doing active task migration in the middle of exec() though [if
there is an inbalance], at that point the task migration interrupt becomes
much more prominent.

	Ingo


