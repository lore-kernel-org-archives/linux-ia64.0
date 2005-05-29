From: Nick Piggin <nickpiggin@yahoo.com.au>
Date: Sun, 29 May 2005 05:49:25 +0000
Subject: RE: ia64 sched-domains initialisation
Message-Id: <429957E5.6060803@yahoo.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42974381.9080000@bull.net>
In-Reply-To: <42974381.9080000@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks like there is some good work happening on the
sched-domains code.

I have no specific comments to any patch, but I would
strongly suggest that if anyone is interested in doing a
lot of sched-domains tuning, that they start with the
scheduler patches in the -mm kernels if possible.

Those patches include a lot of changes, and especially aim
to improve support for multiple NUMA domains, SMT/HT, and
more configurable "load" estimation, among other things.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 
