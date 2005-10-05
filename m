From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Oct 2005 22:09:57 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0495CAF8@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Do you expect a partial write, rather than the EAGAIN?

I suppose you should expect EAGAIN here: http://tinyurl.com/82wr9
describes this situation quite clearly.

So either:
1) ia64 thinks 4120 is less than PIPE_BUF, so that it believes
   that it should not do a partial write
2) Even though we removed some data from the pipe, it thinks that
   it is still all the way full.

[My tests on 2.6.14-rc2].

Which other architectures have you tried this on?  Is ia64 all alone
in failing this test?

-Tony
