From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 06 Jun 2001 16:49:35 +0000
Subject: Re: [Linux-ia64] oops in proc_delete_inode
Message-Id: <marc-linux-ia64-105590693005691@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005690@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005690@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 6 Jun 2001 10:21:30 -0500 (CDT), Jack Steiner <steiner@sgi.com> said:

  Jack> Has anyone seen this failure?

Not me.  I have been stressing 2.4.5 quite heavily on a 2-way Big Sur.
It has been rock solid so far.

  Jack> We recently upgraded to 2.4.5 and have seen this panic twice
  Jack> on different systems. Both panics occured in "top".

What else is running apart from top?  What you describe sounds like
the kinds of problem we were seeing in 2.4.3 with the broken r/w
semaphore.  But I haven't seen any issues like that with 2.4.4 or
2.4.5.

	--david

