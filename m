From: Jes Sorensen <jes@wildopensource.com>
Date: Sun, 13 Feb 2005 21:57:23 +0000
Subject: Re: [rfc] generic allocator and mspec driver
Message-Id: <yq0ll9sp1h8.fsf@jaguar.mkp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <16897.9640.160896.31584@jaguar.mkp.net>
In-Reply-To: <16897.9640.160896.31584@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "David" = David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 03 Feb 2005 15:58:16 -0500, Jes Sorensen <jes@wildopensource.com> said:
Jes> I hear your concerns! However, at the same time, if something
Jes> within the kernel starts mocking with memory it doesn't own,
Jes> thats a bug.

David> I'm not convinced of that.  Jack already mentioned lcrash...

Mmmmm, I took a look at lcrash and I'll refrain from commenting on
it's method of operation here to avoid too much public swearing. Yuck!

Anyway, it seems that lcrash at least only accesses the memory using
read() and write()? which means it is relatively easy to using a
struct page flag to do uncached vs cached access on the fly. mmap on
the other hand would be a bit of a nightmare as it would require a
custom fault handler that would know when to go cached and when not
to.

How would you feel about using PG_arch_1 for this on ia64?

Cheers,
Jes
