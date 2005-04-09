From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 09 Apr 2005 04:32:36 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random problem on 2.6.12-rc1)]
Message-Id: <16983.23268.453958.833658@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 8 Apr 2005 17:28:27 -0700, Matt Mackall <mpm@selenic.com> said:

  Matt> Looks good. Can you verify that
  Matt> /proc/sys/kernel/random/entropy_avail has sane values in it
  Matt> (eg building up to ~3500 and then slowly approaching 4096)?
  Matt> random.c now uses fls and fls(0) was causing all the entropy
  Matt> to vanish.

This appears to be the case.  The highest value I saw was 3732 so I
can't guarantee that it would make it all the way to 4096, but at
least the tendency seems to be right.

	--david
