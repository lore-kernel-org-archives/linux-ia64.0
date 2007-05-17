From: Keith Owens <kaos@sgi.com>
Date: Thu, 17 May 2007 13:05:36 +0000
Subject: Re: [PATCH] get_wchan on running task sometimes MCAs the machine.
Message-Id: <10012.1179407136@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070517111651.GA760@lnx-holt.americas.sgi.com>
In-Reply-To: <20070517111651.GA760@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Robin Holt (on Thu, 17 May 2007 08:00:07 -0500) wrote:
>On Thu, May 17, 2007 at 09:38:59PM +1000, Keith Owens wrote:
>> So even with that check, it can race between not running and running
>> while you do the unwind, and still get the MCA.
>
>To me, this still seems like a reasonable check.  Do you object to
>this patch or are you just pointing out the hole.

No objection to the patch, but the race means that any test on the
task's status is going to be an incomplete fix.  David Mosberger
reckons that unwind should never cause an error, maybe we should be
looking at adding more checks to the unwind code to cope with spurious
addresses?

