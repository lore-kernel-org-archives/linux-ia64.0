From: Grant Grundler <grundler@cup.hp.com>
Date: Fri, 12 Jul 2002 18:02:25 +0000
Subject: Re: [Linux-ia64] Re: switch_mm race condition with Ingo's scheduler
Message-Id: <marc-linux-ia64-105590701905773@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805973@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805973@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote:
> Ah, I see now what you mean.  Yes, you're right it could happen that
> we allocate a context number for a task on one CPU, task gets
> rescheduled, and then we have to flush the TLB when activating the
> context number.

David,
Would "lazy TLB flushing" be possible?
ie flush TLB of given taskid first time task needs to run on a CPU.
Deal with the TLB flushing when running the task,
not when creating or rescheduling to a different CPU.

I'm thinking broadcasting TLB flushes (or IPI for that effect) is, uhm,
less than optimal for scalability. But I'm no expert on CPU TLB issues.
There might be lots of evils with this approach. I need to read
the section on process creation/scheduling in the IA64 Linux book.
(ie you don't need to explain what the book already says).

thanks,
grant

