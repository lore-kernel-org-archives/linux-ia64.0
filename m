From: Dan Pop <Dan.Pop@cern.ch>
Date: Wed, 23 Feb 2000 01:34:40 +0000
Subject: RE: [Linux-ia64] ILP32 support?
Message-Id: <marc-linux-ia64-105590678204963@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678204954@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678204954@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 22 Feb 2000, Vadim Furman wrote:

> IMHO benefits of ILP32 are huge, since you can relatively simply port
> existing 32 apps to ia64 and in the same time enjoy the perfomance of the
> new chip.

Any application assuming that sizeof(int) = sizeof(long) and/or
sizeof(int) = sizeof(type *) is broken by implementation, because
such assumptions are *never* really needed in correctly written code.
The right thing is to fix it. 

Dan



