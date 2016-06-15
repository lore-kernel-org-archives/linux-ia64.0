From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 15 Jun 2016 17:43:48 +0000
Subject: Re: [RFC PATCH-tip v2 5/6] locking/rwsem: Change RWSEM_WAITING_BIAS for better disambiguation
Message-Id: <20160615174348.GT30921@twins.programming.kicks-ass.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
 <1465944489-43440-6-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465944489-43440-6-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <Waiman.Long@hpe.com>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Tue, Jun 14, 2016 at 06:48:08PM -0400, Waiman Long wrote:
> even the reduced maximum of about 16k (32-bit) or 1G (64-bit) should
> be more than enough for the foreseeable future.

So what happens if I manage to create 16k+ threads on my 32bit kernel
and get them all to do mmap() or so at the same time.

That doesn't seem too far fetched.

Then again, with double that (the current limit) that doesn't seem
impossible either.
