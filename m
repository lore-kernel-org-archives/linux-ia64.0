From: Keith Owens <kaos@sgi.com>
Date: Fri, 22 Jul 2005 00:25:03 +0000
Subject: Re: [PATCH]Show registers for all CPUs in the OS_INIT handler
Message-Id: <18231.1121991903@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <C5C58DE4044703indou.takao@jp.fujitsu.com>
In-Reply-To: <C5C58DE4044703indou.takao@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, 22 Jul 2005 09:23:01 +0900, 
Takao Indoh <indou.takao@soft.fujitsu.com> wrote:
>Hi,
>
>On Fri, 22 Jul 2005 01:20:13 +1000, Keith Owens wrote:
>
>>On Thu, 21 Jul 2005 20:04:51 +0900, 
>>Takao Indoh <indou.takao@jp.fujitsu.com> wrote:
>>>When OS_INIT handler is called, the registers of monarch CPU are dumped
>>>but the registers of slave CPU are not. It is very inconvenient because
>>>ip cannot be identified on slave cpus.
>>>I'd like to change OS_INIT handler to show registers of all CPUs.
>>
>>Please hold off on this patch.  I have a rewrite that cleans up the MCA
>>and INIT handlers, and gives clean backtraces for both monarch and
>>slave INIT handlers.
>
>Ok, I'll wait for your cleanup patch. When is your patch released?

Next week I hope.  It is up to the point of switching to separate
stacks for MCA and INIT (both monarch and slave) and even recovering
from INIT.  The backtrace data for the original tasks is not right yet.

