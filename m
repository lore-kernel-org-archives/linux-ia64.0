From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 29 Oct 2001 18:52:08 +0000
Subject: Re: [Linux-ia64] itc sync & clock_*
Message-Id: <marc-linux-ia64-105590698805410@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805400@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805400@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 29 Oct 2001 12:33:37 -0600 (CST), Jack Steiner <steiner@sgi.com> said:

  Jack> I sent mail to Asit last week about this.

Yes, I know of these discussions.  However, I don't think anything has
been settled yet.  Some people prefer to put this info in ACPI for
example.  Personally, I like the SAL approach, but the point is that
the firmware folks need to agree on something before we can start
using it.

BTW: I do not like the name "ITC_UNSYNCHRONIZED".  The issue is not
synchronization (we take care of that when booting the kernel).  The
issue is *drift* (and, to a secondary degree, ITC frequency).

	--david

