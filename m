From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 08 Apr 2002 17:26:23 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905408@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 8 Apr 2002 09:00:42 -0700, Gary Hade <garyhade@us.ibm.com> said:

  Gary> Would it be okay in the Linux world for an application written
  Gary> in C++ to use a system call such as query_module(2)?

Of course.

  Gary> If so,
  Gary> the application code would include <linux/module.h>.
  Gary> <linux/module.h> includes <asm/atomic.h> on a line which is
  Gary> not within an #ifdef __KERNEL__ region so the same C++ compile
  Gary> failure will occur.

No, glibc needs to provide its own headers for this purpose.

	--david

