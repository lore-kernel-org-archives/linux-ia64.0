From: Keith Owens <kaos@ocs.com.au>
Date: Thu, 21 Aug 2003 01:46:00 +0000
Subject: Re: libunwind
Message-Id: <marc-linux-ia64-106143042731025@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106141788020789@msgid-missing>
In-Reply-To: <marc-linux-ia64-106141788020789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 20 Aug 2003 17:05:10 -0700, 
Umut Aymakoglu <umuta@us.ibm.com> wrote:
>I need to put stack tracing into my program. To use the libunwinding , i
>need to link with the library which will cause problems for the customers
>who do not have the libunwind library.

ksymoops has the same problem, it needs libbfd and libiberty which are
not always installed.  Link libunwind statically with your program and
use dynamic linking for everything else.

 ld ... -Wl,-Bstatic -lunwind -Wl,-Bdynamic -o ...

People who install the binary have no problems, only people who want to
compile the program themselves need to install libunwind.

