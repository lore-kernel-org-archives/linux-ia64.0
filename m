From: Keith Owens <kaos@sgi.com>
Date: Sun, 23 Feb 2003 22:06:31 +0000
Subject: [Linux-ia64] Re: Bug: Blocking of RT signals in a pause()
Message-Id: <marc-linux-ia64-105590709805909@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 21 Feb 2003 17:38:24 +0100, 
Eric Piel <Eric.Piel@Bull.Net> wrote:
>Basically the problem is that while my program is in a pause() I can not
>receive any signal > 32 (RT signals) even if I've just unblocked them.
>In addition if I unblock signal 32 then all the RT signals are
>unblocked. This strange behaviour is not reproductible during a sleep().
>No idea came to my mind to test other system calls so I can't say more.

This is a glibc bug, see http://lists.linuxia64.org/archives/linux-ia64/2003-January/004578.html.
I have sent this bug twice to the libc-alpha list, with no response.
Third bug report is on its way to libc-alpha.


