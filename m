From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Sun, 21 Feb 2021 09:21:56 +0000
Subject: Re: [PATCH] ia64: fix ptrace(PTRACE_SYSCALL_INFO_EXIT) sign
Message-Id: <66569d56-1af0-a6bb-8b54-9d1cded893cd@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210221002554.333076-1-slyfox@gentoo.org>
 <20210221002554.333076-2-slyfox@gentoo.org>
In-Reply-To: <20210221002554.333076-2-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, "Dmitry V . Levin" <ldv@altlinux.org>

Hi Sergei!

On 2/21/21 1:25 AM, Sergei Trofimovich wrote:
> In https://bugs.gentoo.org/769614 Dmitry noticed that
> `ptrace(PTRACE_GET_SYSCALL_INFO)` does not return error sign properly.
> (...)

Do these two patches unbreak gdb on ia64?

And have you, by any chance, managed to get the hpsa driver working again?

Adrian

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
