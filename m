From: Rick Lindsley <ricklind@us.ibm.com>
Date: Mon, 22 Nov 2004 21:27:55 +0000
Subject: Re: [Lse-tech] scalability of signal delivery for Posix Threads
Message-Id: <200411222127.iAMLRtN7020062@owlet.beaverton.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: Your message of "Mon, 22 Nov 2004 09:51:15 CST."
             <41A20AF3.9030408@sgi.com> 
References: <20041122162214.GE21861@wotan.suse.de>
In-Reply-To: <20041122162214.GE21861@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ray Bryant <raybry@sgi.com>
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, lse-tech <lse-tech@lists.sourceforge.net>, holt@sgi.com, Dean Roe <roe@sgi.com>, Brian Sumner <bls@sgi.com>, John Hawkes <hawkes@tomahawk.engr.sgi.com>

So with CLONE_SIGHAND, we share the handler assignments and which signals
are blocked, but retain the ability for individual threads to receive
a signal.  And when all of them receive signals in quick succession,
we see lock contention because they're sharing the same (effectively)
global lock to receive all of their (effectively) individual signals
.. is that correct?

Are you contending on tasklist_lock, or on siglock?

    It seems to me that scalability would be improved if we moved the
    siglock from the sighand structure to the task_struct.

Only if you want to keep its current semantics of it being a lock for
all things signal.  Finer granularity would, it seems at first look,
afford you the benefits you're looking for.  (But not without the cost of
a fair amount of work to make sure the new locks are utilized correctly.)
For the problem you're describing, it sounds like the contention is occuring
at delivery, so a new lock for pending, blocked, and real_blocked might be
in order.

Rick
