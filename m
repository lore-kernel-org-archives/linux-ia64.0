From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 05 Sep 2001 00:52:07 +0000
Subject: Re: [Linux-ia64] can't compile on x86 - building cross-compiler for ia64 getting SIGSEGV
Message-Id: <marc-linux-ia64-105590698805120@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805115@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805115@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 3 Sep 2001 12:44:16 -0700 (PDT), 
k Macy <kip_macy@yahoo.com> wrote:
>Is it actually possible to cross-develop from x86?

Current gcc code will not cross compile from ix86 to ia64, it gets
problems with conditional return of 64 bit values in some functions.
Disabling optimization for some directories avoids the problem, but is
too messy as a long term solution.  Report the bug to gcc.


