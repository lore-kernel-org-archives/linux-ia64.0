From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 15 Jan 2002 19:52:37 +0000
Subject: Re: [Linux-ia64] Help with Ingo scheduler on IA64
Message-Id: <marc-linux-ia64-105590698805832@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805816@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805816@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 15 Jan 2002, Erich Focht wrote:

> the appended patch almost does the job for IA64. On my BigSur 2.4.17 +
> ia64 + Ingo's_O(1)_I0 + ia64add.patch dies silently somewhere after
> init checked the filesystems, sometimes the last message beeing "INIT:
> Entering runlevel: 3" or "Mounting local filesystems:". When trying to
> boot with the "emergency" option added, it dies right after I enter
> the root password, but it doesn't always reach this point :-(

is this with 1 CPU?

	Ingo


