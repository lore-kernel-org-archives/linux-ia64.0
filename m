From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 15 Oct 2003 22:51:15 +0000
Subject: Re: [PATCH] a little more documentation in fsys.txt
Message-Id: <marc-linux-ia64-106625829219963@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106574771001988@msgid-missing>
In-Reply-To: <marc-linux-ia64-106574771001988@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 10 Oct 2003 14:01:29 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

>>>>> On Fri, 10 Oct 2003 10:55:54 +1000, Ian Wienand <ianw@gelato.unsw.edu.au> said:
  Ian> Hi, Attached is a suggestion for a small addition to fsys.txt
  Ian> about how userspace can use fast system calls.

  Ian> If people think this is totally wrong, or that something like
  Ian> this might be more appropriate in our WiKi, that's fine.

  David> I like the idea of improving the documentation, but since
  David> we're in bug-fix-only mode, I won't be able to apply the
  David> patch for now.  Please resend when 2.7 is open.

Actually, it seems silly to discourage documentation improvements.  If
anything, we should encourage them as 2.6.0 stabilizes (as long as
we're talking about updating real documentation, not just munging
comments for typos etc.).  I checked with Andrew and he seems OK with
such updates, so I applied this patch to my tree now.

Thanks,

	--david
