From: Richard Henderson <rth@redhat.com>
Date: Sat, 23 Feb 2002 00:58:08 +0000
Subject: [Linux-ia64] Re: problem with unwind info for .init/.fini sections
Message-Id: <marc-linux-ia64-105590701905180@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 22, 2002 at 11:54:27AM -0800, David Mosberger wrote:
> While we found the problem with ia64 linux, I suspect other
> platforms that rely on unwind info are likely to be affected as well.

This is .init -- why do you care if you can unwind through it?


r~

