From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 Feb 2004 00:03:04 +0000
Subject: Re: [patch] 2.6.3 sync unwind code with 2.4.25
Message-Id: <16442.38072.25672.884760@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4545.1077507994@kao2.melbourne.sgi.com>
In-Reply-To: <4545.1077507994@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 24 Feb 2004 10:53:33 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> One line fix for 2.6.3.  include/linux/compiler-gcc3.h defines inline
  Keith> which gives warnings for unwind.c when UNW_DEBUG is defined.

Yeah, that's a feature, actually.  It reminds me to turn off UNW_DEBUG
before shipping a kernel...

	--david
