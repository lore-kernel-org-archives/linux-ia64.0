From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 13 Aug 2001 19:31:04 +0000
Subject: Re: [Linux-ia64] incorrect misalignment handling
Message-Id: <marc-linux-ia64-105590698805065@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805060@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805060@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sun, 12 Aug 2001 09:58:48 +0300, "Zach, Yoav" <yoav.zach@intel.com> said:

  Yoav> The problem is that fsz=e means the operation length is 10
  Yoav> bytes, and not 16 bytes as in the implementation. Attached is
  Yoav> a small test case that demonstrates this problem.

  Yoav> Is there a rationale behind this implementation, or is it just
  Yoav> a mistake ?

Looks like a bug to me.

  Yoav> * If it is a mistake, was it corrected in kernel versions
  Yoav> later than 2.4.3 ?

No, you're the first person to report this issue.  I'll look into
fixing this.  The bug also affects the "load" side (you could see a
page fault that otherwise you wouldn't see on a CPU that did the
unaligned access in hardware).

	--david

