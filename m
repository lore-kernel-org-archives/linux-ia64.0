From: Richard Henderson <rth@redhat.com>
Date: Mon, 08 Apr 2002 05:52:19 +0000
Subject: [Linux-ia64] Re: epilogue count exceeds number of nested prologues
Message-Id: <marc-linux-ia64-105590701905404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sun, Apr 07, 2002 at 05:17:14PM -0700, Randolph Chung wrote:
> The offending assembly code is attached. it's the ".restore sp" near
> the end that is triggering the error.

Yes, this assembly is completely scrogged.  It's all inside inline
assembly too, so it's no one's fault but the programmer.

That said, you must be using an old libffi, since the one in gcc
cvs works just fine.


r~

