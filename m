From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 05 Feb 2002 01:35:16 +0000
Subject: Re: [Linux-ia64] cmpxchg patch
Message-Id: <marc-linux-ia64-105590698805988@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805982@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805982@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 02 Feb 2002 10:26:42 -0600, Ray Bryant <raybry@engr.sgi.com> said:

  Ray> It seems to me that the size of the result of
  Ray> cmpxchg(ptr,old,new) should depend on the size of *ptr and not
  Ray> the size of old.

  Ray> Attached is a patch to fix.

Have you actually tried building a kernel with the patch applied?  I
think you'll get errors in atomic.h.  I'm willing to entertain a
better solution, but it needs to be a complete solution.

Thanks,

	--david

