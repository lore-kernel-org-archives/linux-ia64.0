From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 06 Oct 2016 22:51:46 +0000
Subject: Re: [RFC PATCH-tip v4 02/10] locking/rwsem: Stop active read lock ASAP
Message-Id: <20161006225146.GA30561@linux-80c1.suse>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
 <1471554672-38662-3-git-send-email-Waiman.Long@hpe.com>
 <20161006181718.GA14967@linux-80c1.suse>
 <20161006214751.GU27872@dastard>
In-Reply-To: <20161006214751.GU27872@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Chinner <david@fromorbit.com>
Cc: Waiman Long <Waiman.Long@hpe.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Fri, 07 Oct 2016, Dave Chinner wrote:

>Except that it's DAX

Duh, of course; silly me.

Thanks,
Davidlohr
