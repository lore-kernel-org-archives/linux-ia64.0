From: "Boehm, Hans" <hans_boehm@hp.com>
Date: Thu, 26 Jul 2001 20:18:56 +0000
Subject: RE: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
Message-Id: <marc-linux-ia64-105590693005929@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005928@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005928@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Jose Luu [mailto:jluu@mainsoft.com]
> Sent: Thursday, July 26, 2001 12:51 PM
> To: linux-ia64@linuxia64.org
> Subject: [Linux-ia64] gcc 3.0 question: ILP32 mode ?
> 
> 
> 
> This report 
> http://www.linuxia64.org/gcc_summit.2001.06.06.html mentions
> that:
> > the HP-UX version of GCC on IA-64 supports
> >   ILP32 as well as LP64
> 
> Is this also available on linux gcc 3.0 ?
No.

> If not, how difficult would it be to make such a version ?
How are you going to run the resulting code?  The kernel doesn't support it.
Neither do the libraries installed on any system.  Neither do any ISV
libraries.  Nor in all probability should they, since that raises the
possibility of applications that can't be built because it relies on one
library that's only available as ILP32 and another that's LP64.

> In case I want to undertake it, ...
If this requires building another version of standard libraries, you don't
want to do this, given that Linux/Itanium can run X86 binaries on Linux.
Supporting another ABI is very expensive.  The tradeoffs for HP/UX are
different.

Hans

