From: Keith Owens <kaos@sgi.com>
Date: Wed, 13 Mar 2002 14:08:17 +0000
Subject: Re: [Linux-ia64] Exception handling and recovery
Message-Id: <marc-linux-ia64-105590701905258@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905250@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905250@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Mar 2002 07:58:32 -0600 (CST), 
Jack Steiner <steiner@sgi.com> wrote:
>I may have missed the context of the question, but on IA64 if kdb 
>makes a reference to a bad region 6 or 7 pointer, it may trigger an MCA.
>MCAs are not recoverable via search_exception_table(). 

Agreed, but some recoverable errors are not currently checking the
exception table.  For example, sys_query_module = 0xe000000000a64000,
id 0xc000000000a64000 (same address, but region 6) fails with 'General
Exception: IA-64 Reserved Register/Field fault (data access)'.  The
more resilient I can make kdb, the better I like it, hence my wish to
add recovery to ia64_fault().


