From: Jesse Barnes <jbarnes@sgi.com>
Date: Thu, 25 Apr 2002 01:01:59 +0000
Subject: [Linux-ia64] Re: PCI DAC routines for SN
Message-Id: <marc-linux-ia64-105590701905524@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905493@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905493@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Apr 24, 2002 at 05:43:18PM -0700, David S. Miller wrote:
> We don't add things to Linux that we "might need" we add things
> we actually need.  It is a slight performance problem too.

I fully understand and agree with that, and I don't propose adding the
call just for the fun of it.  It's just that most of the time, it's
easier software-wise to use the 64 bit consistent mappings if your
device can support it (e.g. generic ia64, ia64/sn).

> I don't think the hardware folks would be happy to hear that you're
> willing to sacrifice real hardware cycles just for some DAC nirvana
> or whatever it is you have for this issue.

I don't think the performance impact of those extra cycles would be
measurable, but I'd be happy to see any numbers you might have to the
contrary.

Jesse

