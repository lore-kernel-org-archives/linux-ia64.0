From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Oct 2005 23:40:24 +0000
Subject: RE: [Fwd: Weird ia64 problem]
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0495CCA3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1128548614.4623.45.camel@laptop1>
In-Reply-To: <1128548614.4623.45.camel@laptop1>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>This implies that PIPE_BUF should be equal to the kernel's configured
>page size on ia64.  I modified my test to report on PIPE_BUF's returned
>value, and it is 4096 on all my tested architectures, including ia64 on
>2.6.8 and 2.6.12.

Hmmph.  According to strace, there are no system calls resulting from
the fpathconf() call.  How does it come up with the magic 4096 value?

-Tony
