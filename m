From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 12 Mar 2003 18:07:30 +0000
Subject: Re: [Linux-ia64] page size > 16KB
Message-Id: <marc-linux-ia64-105590709806064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806057@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806057@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 12 Mar 2003 09:49:41 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> Really?  What sorts of benchmarks have you done that show
  Jesse> large improvements?  I ask because I can think of a few that
  Jesse> might benefit, but have yet to see real world improvements of
  Jesse> any significance, so I'm curious.

Anything that's hurt significantly by TLB pressure will gain
signifcantly.  Even apps that stream through memory (e.g., STREAMS)
can see significant gains.  Other advantages are more reproducible
results (since you're effectively getting some page coloring for
"free") and much larger user virtual address space.

However, the part that really surprised me is how little ordinary apps
seem to suffer from the higher page-fault latency and increased
internal fragmentation.  I don't recall the exact numbers, but even a
kernel compile ran almost as fast with 64KB page size as with 16KB
page size.

If you know of a real-world application that suffers significantly
from 64KB page size, I'd like to hear about it.

	--david

