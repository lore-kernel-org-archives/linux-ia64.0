From: Ingo Molnar <mingo@elte.hu>
Date: Sat, 20 Jul 2002 17:16:59 +0000
Subject: [Linux-ia64] Re: [PATCH]: scheduler complex macros fixes
Message-Id: <marc-linux-ia64-105590701905789@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905791@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 19 Jul 2002, Erich Focht wrote:

> Thanks. But as long as SCHED_BATCH ins't in 2.5.X, we need this separate
> fix. And if it's in the main tree, you don't need it additionally in
> your patches. The fix is O(1) specific and I thought it should not hide
> inside the SCHED_BATCH patches, some people might encounter these
> problems...

well, SCHED_BATCH is in fact ready, so we might as well put it in. All the
suggestions mentioned on lkml (or in private) are now included, there are
no pending (known) problems, no objections, and a number of people are
using it with success.

	Ingo


