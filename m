From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Nov 2002 00:55:13 +0000
Subject: Re: [Linux-ia64] sigcontext structure
Message-Id: <marc-linux-ia64-105590709805417@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701906086@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701906086@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Nov 2002 12:42:20 -0600, "shiva chetan" <chetan@uiuc.edu> said:

  Chetan> Hi, The sigcontext structure of linux/i386 has the following
  Chetan> fields

  Chetan> trapno (stores trap number) err (stores faulting address)
  Chetan> cr2 (contains type of fault)

  Chetan> what are the equivalent fields in the sigcontext structure
  Chetan> of linux/ia64 ?  its not very apparent from the definition
  Chetan> of the structure.

There is no 1-to-1 correspondence, but such info is stored in siginfo
on ia64.  See siginfo.h.

	--david


