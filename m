From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 15 Jan 2002 20:12:39 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805835@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Jan 2002, Ingo Molnar wrote:

> > no, it's with 2 CPUs. Does it make sense to try without CONFIG_SMP?
>
> yes, UP scheduling is much simpler.

that having said, i've implemented & tested the O(1) scheduler purely on
SMP. But the UP port took about 5 minutes, and the UP kernel worked on the
first bootup. In your case it might make sense to first test UP and then
go over to SMP. If there is some fundamental problem it's much easier to
debug & fix it on UP.

	Ingo


