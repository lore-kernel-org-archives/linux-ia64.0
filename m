From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 21 Aug 2008 23:11:32 +0000
Subject: RE: linux-next: ia64 allmodconfig
Message-Id: <57C9024A16AD2D4C97DC78E552063EA309EDDD52@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080820233526.14c44ea6.akpm@linux-foundation.org>
In-Reply-To: <20080820233526.14c44ea6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Not sure if this is helpful, but google pointed me at:
> http://www.mail-archive.com/gcc-bugs@gcc.gnu.org/msg116574.html

That said "Fixed in 4.0.0" ... so I grabbed and built a newer
gcc (4.2.4) and lo and behold the next-20080821 tag builds
and boots just fine[*] with it.

Still need to figure out exactly what broke the build with
a 3.x gcc to see if there is an easy workaround. Though 4.0.0
was released over three years ago ... is it time to give up
on the ancient 3.x technology?

-Tony

[*] If you ignore that the 4.2.4 compiler is about 15% slower
than my trusty old 3.4.6 :-(
