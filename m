From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Oct 2005 22:33:51 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0495CB62@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Do you expect a partial write, rather than the EAGAIN?
>
>That appears to be what's happening in most other cases, and also
>appears to be what the LSB tests want.

Running with a kernel configured for 4K pagesize, this
test passes (prints "the write appeared to succeed").

I expect this difference in behavior can be traced to when
Linus improved pipe performance by allowing a list of many
pages to implement the pipe buffer.  See http://tinyurl.com/7jfen

The date on this is Jan 6th, 2005 ... which puts it between
2.6.10 and 2.6.11-rc1

-Tony
