From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 15 Mar 2002 19:51:47 +0000
Subject: Re: [Linux-ia64] mmap limits
Message-Id: <marc-linux-ia64-105590701905298@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905276@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905276@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 18:07:06 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> Hi, Is there any architectural reason why one should not be
  Peter> able to mmap more than 2GB from /dev/zero, assuming there's
  Peter> enough physical memory plus swap?

No.

  Peter> At present atempts to mmap more than 2G fail with ENOMEM, and
  Peter> I believe this is a bug.

Yes, sounds like it.

	--david

