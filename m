From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 18 Nov 2003 17:47:41 +0000
Subject: RE: [RFC] How drivers notice a MCA on I/O read? [1/3]
Message-Id: <marc-linux-ia64-106917774129945@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> This would not only be useful for the occasional device failure, but
> also for accessing memory spaces which by definition may or may not
> respond to PIO requets, like legacy I/O bus and memory regions.  Upon
> entering readb_check(), you could set a global telling the MCA handler
> to potentially expect a failure from the address or range that was
> passed in.  This would allow the MCA handler describe in simple terms
> what went wrong in case of failure and/or take appropriate action.

As Zoltan mentioned in his mail you'd have to do some heavy fencing
around the internals of readb_check() to make this safe ... which
might make readb_check() too expensive to use for the 99.999999% of
the cases where the I/O board isn't broken.  But I don't actually know
how much overhead would be involved ... I/O reads are already horrendously
slow, so you may be able to add some sizeable overhead without affecting
macro benchmarks more than a few percent.

-Tony
