From: Robert Nagy <robert.nagy@gmail.com>
Date: Tue, 26 Jun 2007 16:58:56 +0000
Subject: Re: intercept trap when running a 32bit binary
Message-Id: <20070626165856.GA4140@bsd.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070625221349.GA25054@bsd.hu>
In-Reply-To: <20070625221349.GA25054@bsd.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On (26/06/07 09:30), Luck, Tony wrote:
> Bother.  Another thing to try might be to use strace (the x86 version
> in your chroot subtree) to see how far the program gets before it
> dies.  If you have a native x86 system to compare this strace output
> with what is supposed to happen, that would be even better.

Hi

Here is the output http://humppa.hu/typescript

This is the only linux system i have, but I can provide
almost the same output running the same program on OpenBSD
with the linux binary compat.
