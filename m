From: Keith Owens <kaos@sgi.com>
Date: Tue, 17 Dec 2002 03:43:50 +0000
Subject: Re: [Linux-ia64] Re: gas generates incorrect ia64 unwind rlen values
Message-Id: <marc-linux-ia64-105590709805595@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805569@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805569@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 16 Dec 2002 19:25:39 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>Why do you insist on re-discovering old bugs?  For the code in
>question, the problem is caused by the jump-table generated for the
>switch-statement.  gcc 2.9x placed jump-tables in the text section,
>which violates the ia64 ABI and also confuses the assembler.

Which version of gcc to use is not my decision, I have to use 2.96 :(.
Thanks anyway.


