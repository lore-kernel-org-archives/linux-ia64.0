From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 22 May 2003 17:58:48 +0000
Subject: [Linux-ia64] Re: web page on O(1) scheduler
Message-Id: <marc-linux-ia64-105590723705985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705966@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705966@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 22 May 2003 18:25:54 +0200, Mike Galbraith <efault@gmx.de> said:

  Mike> Out of curiosity, is someone hitting that with a real program?

Yes, it caused a failure in a validation program.  The test case is a
stripped-down version of the original program and, of course, doesn't
make much sense other than to demonstrate the scheduling problem.

	--david

