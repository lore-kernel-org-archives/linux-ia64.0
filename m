From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 15 Jan 2002 19:57:50 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805834@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Jan 2002, Erich Focht wrote:

> > is this with 1 CPU?
>
> no, it's with 2 CPUs. Does it make sense to try without CONFIG_SMP?

yes, UP scheduling is much simpler.

	Ingo


