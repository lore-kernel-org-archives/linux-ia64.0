From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 08 Mar 2002 08:12:31 +0000
Subject: Re: [Linux-ia64] VHPT performance
Message-Id: <marc-linux-ia64-105590701905239@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905139@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905139@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 08 Mar 2002 08:50:15 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Could you please try with my test program to verify what
  Christian> I found (compile with -O). The pointer increment is half
  Christian> the page size, so TLB hit and TLB miss are changing.

I think it's your program: I suspect you're measuring cache misses
more than anything else.  Try touching a set of pages repeatedly and
try to touch different words, such that there are no cache misses.

	--david

