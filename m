From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 26 Apr 2007 20:41:46 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <20070426204146.GA25142@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
In-Reply-To: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Keilty <peter.keilty@hp.com>
Cc: linux-ia64@vger.kernel.org, John Stultz <johnstul@us.ibm.com>, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

On Thu, Apr 26, 2007 at 04:26:32PM -0400, Peter Keilty wrote:
> From: Peter Keilty <peter.keilty@hp.com>
> 
> Initial ia64 conversion to the generic timekeeping/clocksource code.
> 
> Signed-off-by: Peter Keilty <peter.keilty@hp.com>
> Signed-off-by: John Stultz <johnstul@us.ibm.com>

The "Signed-off-by:" should reflect the order in which a path is processed
with the last submitter at the bottom of the list.
So if this patch came from John then he should be first in the list
and since the patch passes you and you submit it you should be in the bottom
of the list.

And "Signed-off-by:" tell the path that the patch takes. It is not to be used
to let others say "I have seen it and I think the patch is ok".
For the latter we have "Acked-by:".

I did not look at the code so ne feedback there.

	Sam
