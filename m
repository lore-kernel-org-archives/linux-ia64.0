From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 05 Apr 2002 21:54:27 +0000
Subject: Re: [Linux-ia64] C++ doesn't like asm/atomic.h
Message-Id: <marc-linux-ia64-105590701905397@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905396@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905396@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 5 Apr 2002 13:40:34 -0800, Gary Hade <garyhade@us.ibm.com> said:

  Gary> asm/atomic.h is not palatable to C++ due to it's use of the
  Gary> C++ keyword "new".

Eh, the kernel is written in C.  If you have an application that
includes a kernel header, fix the application---it's broken.  (This
has been Linus' edict for the last N years, for some N > 3...)

	--david

