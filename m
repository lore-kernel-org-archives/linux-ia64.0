From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 22 Feb 2002 18:49:10 +0000
Subject: Re: [Linux-ia64] Linux IA64 ToDo List
Message-Id: <marc-linux-ia64-105590701905177@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905170@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905170@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 22 Feb 2002 09:57:05 -0700, n0ano@indstorage.com said:

  Don> Anyone else?

I'm continuing to working on the unwind library (and its API).  Local
stacktraces, (gcc) exception handling, and remote stack traces are
working now.  Next is getting gdb to use the unwind library.

The next thing I plan to do is to streamline the system call path.
The goal primarily is to avoid saving/restoring the scratch registers,
but it's likely that I'll also toy around with lightweight system
calls.

	--david

