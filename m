From: "Jose Luu" <jluu@mainsoft.com>
Date: Thu, 26 Jul 2001 22:42:25 +0000
Subject: Re: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005937@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hans wrote:
> Supporting another ABI is very expensive.  The tradeoffs for HP/UX are
> different.
>

I am sure I don't realize how expensive it is, but it seems worth
investigating, for our purposes we need the libc and libX11, little else.

Some code is just not worth cleaning up because it is too big, and will
never require 64 bit addressing, but still useful to have in native mode,
mostly because of the performance gap between ia32 and ILP32 which will
moreover widen with the McKinley chip. Look at netscape, it has never been
cleaned up, it was ported on linux alpha using the DEC/Compaq/(Intel now?)
compiler in taso mode (32 bit pointers).

DEC/Compaq developped a technology for VMS where one can mix 32 and 64 bit
libraries, I am wondering if the same ideas can be applied here (see
references below), nowadays this technology should be with Intel. This would
avoid the fork in the ABI.

References:
http://www.research.compaq.com/wrl/DECarchives/DTJ/DTJM06/DTJM06HM.HTM and
http://www.research.compaq.com/wrl/DECarchives/DTJ/DTJM07/DTJM07HM.HTM

Jose


