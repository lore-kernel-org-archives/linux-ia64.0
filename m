From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 05 Oct 2000 17:49:39 +0000
Subject: Re: [Linux-ia64] Error compiling c++ support with glibc 2.2
Message-Id: <marc-linux-ia64-105590678205545@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205544@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205544@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have since noticed that the same bug got reported to gcc-bugs, and a
patch was applied Sept 23 which should fix this problem.  I have not yet
tried to extract the patch and test it.

2000-09-23  Franz Sirl  <Franz.Sirl-kernel@lauterbach.com>

	    * stdstreams.cc: Include <libio.h>, not "libio.h".
	    * iolibio.h: Likewise.
	    (_IO_pos_BAD): Use _IO_off_t instead of _IO_fpos_t.
	    * libio.h (_IO_USER_LOCK): Define.

http://gcc.gnu.org/ml/gcc-bugs/2000-09/msg00563.html

Jim

