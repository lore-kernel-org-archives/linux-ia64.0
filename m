From: Uros Prestor <uros@turbolinux.com>
Date: Tue, 08 Aug 2000 19:43:53 +0000
Subject: Re: [Linux-ia64] Kernel: which machine to choose?
Message-Id: <marc-linux-ia64-105590678205285@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:

> Did you upgrade the compiler as well to a more recent snapshot?

No, we are using Cygnus May release with additional patches.

> Did you include Dan's hand optimized string/mem routines in your glibc
> package?

No -- they are disabled both in 0505 and in 0714 releases because A1
boxes would freeze in about 5-10 minutes with optimized memory functions
enabled.  I haven't tested optimized string/mem functions with A2/A3,
though.

Uros

--
Uros Prestor
uros@turbolinux.com




