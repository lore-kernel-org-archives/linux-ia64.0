From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Jan 2003 16:23:48 +0000
Subject: Re: [Linux-ia64] fsyscall-support
Message-Id: <marc-linux-ia64-105590709805680@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805677@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805677@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 14 Jan 2003 22:36:32 -0800, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> I believe the design and the implementation of the fsyscall
  David> support is safe and has no outstanding holes (well, at least
  David> none that I know of).

5 minutes after sending this off, I realized that in the excitment of
it all, I forgot to handle asynchronous signal delivery.  I'll fix
that in the next patch (the fix shouldn't affect the overhead for
lightweight syscalls at all).

	--david

