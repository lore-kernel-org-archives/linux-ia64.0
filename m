From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 17 Jan 2002 09:45:54 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805867@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 16 Jan 2002, Nick Pollitt wrote:

> With this hack, I'm getting an SMP boot all the way to the init script
> 'Checking for new Hardware [OK]' before the hang.

i'd suggest to remove the dont_clear thing from sched.c, unless there are
other reasons to it, apart from working around the task migration bug.

	Ingo


