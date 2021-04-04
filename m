From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sun, 04 Apr 2021 20:53:14 +0000
Subject: Re: [PATCH] ia64: module: fix symbolizer crash on fdescr
Message-Id: <a83c7df8-5747-9f88-11f8-94834ce36199@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210403074803.3309096-1-slyfox@gentoo.org>
In-Reply-To: <20210403074803.3309096-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi Sergei!

On 4/3/21 9:48 AM, Sergei Trofimovich wrote:
> Noticed failure as a crash on ia64 when tried to symbolize all
> backtraces collected by page_owner=on:
> 
>     $ cat /sys/kernel/debug/page_owner
>     <oops>
> 
>     CPU: 1 PID: 2074 Comm: cat Not tainted 5.12.0-rc4 #226
>     Hardware name: hp server rx3600, BIOS 04.03 04/08/2008
>     ip is at dereference_module_function_descriptor+0x41/0x100
> 
> Crash happens at dereference_module_function_descriptor() due to
> use-after-free when dereferencing ".opd" section header.
> 
> All section headers are already freed after module is laoded
> successfully.
> 
> To keep symbolizer working the change stores ".opd" address
> and size after module is relocated to a new place and before
> section headers are discarded.
> 
> To make similar errors less obscure module_finalize() now
> zeroes out all variables relevant to module loading only.

Typo: s/zeroes/zero/.

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
