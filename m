From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 08 Oct 2003 17:52:38 +0000
Subject: Re: [PATCH] small cleanups + fixes for perfmon.c
Message-Id: <marc-linux-ia64-106563594518375@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106562332002217@msgid-missing>
In-Reply-To: <marc-linux-ia64-106562332002217@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

John,

On Wed, Oct 08, 2003 at 03:20:02PM +0100, John Levon wrote:
> 
> The following patch, compile-tested only so far, does the following :
> 
> o removes the [UN]LOCK_BUF_FMT_LIST defines - there is no abstraction
>   benefit to them, and they just look ugly
> o fixes two KERN_ERR that should be KERN_INFO
> o removes the "nolock" parameter to the find function (was unused)
> o homogenises the names related to buffer formats
> o removes the hand-crafted list in favour of standard linux list methods
> o reduces code duplication
> 
> OK ?
> 
Yes, that one looks fine to me. I will apply it
to me version and then submit this to David.

Thanks for the cleanups.

-- 
-Stephane
