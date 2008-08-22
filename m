From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Aug 2008 23:34:03 +0000
Subject: RE: linux-next: ia64 allmodconfig
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309EDE4A9@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I tried 4.3.1 and got:
>
> configure: error: Building GCC requires GMP 4.1+ and MPFR 2.3.0+.
>
> So I'll have to do some other upgrading and installing on my
> ancient build box to make this work :-(

I moved my build tools over to a newer, faster box.  gcc4.3.1 built
with no problems ... and built some kernels which seem to be
working just fine.

-Tony
