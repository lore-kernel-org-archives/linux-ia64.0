From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 10 May 2003 07:01:48 +0000
Subject: Re: [Linux-ia64] executable data segment ?
Message-Id: <marc-linux-ia64-105590723705720@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705718@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705718@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 10 May 2003 10:00:24 +0530 (IST), CH Gowri Kumar <gkumar@csa.iisc.ernet.in> said:

  >> Is there a way in linux on ia64 to execute code in the
  >> datasegment ?

  > Yes, it is possible to execute code in the data
  > segment.  The data segment by default is not executable. You
  > might have to make it executable using the mprotect system call.

And if you want to be able to get a backtrace through dynamically
generated code, please consider using the dynamic unwind info API of
libunwind (http://www.hpl.hp.com/research/linux/libunwind/).  No
man-page yet, I'm afraid, but there is an example in the libunwind
source distribution (tests/ia64-test-dyn1.c) which should make it
obvious how to use this API.

Imagine being about to use gdb to debug your dynamically-generated
code!

	--david

