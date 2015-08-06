From: Matthew Leach <matthew@mattleach.net>
Date: Thu, 06 Aug 2015 16:13:14 +0000
Subject: Re: [BUG]: Intel uncore boot warning introduced in 4.1
Message-Id: <87bneko0o5.fsf@mattleach.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1438853676.3139.20.camel@mattleach.net>
In-Reply-To: <1438853676.3139.20.camel@mattleach.net> (Matthew Leach's message
	of "Thu, 06 Aug 2015 10:34:36 +0100")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@kernel.org>
Cc: Kan Liang <kan.liang@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi Ingo,

Matthew Leach <matthew@mattleach.net> writes:

[...]

> I've bisected the kernel and found that commit [2] seems to introduce
> the warning message.  I have checked on a v4.2-rc5 kernel and the
> warning message is still there.

[...]

> [2]: 8cf1a3de97804b047973dd44cfacdc1930da8403

Apologies, I got it wrong.  The commit that is causing the issue is [1].
If I revert it, the warning goes away.  I'm also testing to see if this
is the cause of the random freezing that occurs (which I can confirm is
also happening with v4.2-rc5).

[1]: 15c1247953e8a45232ed5a5540f291d2d0a77665

Thanks,
-- 
Matt
