From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 30 Aug 2002 19:00:33 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.5.32)
Message-Id: <marc-linux-ia64-105590701906004@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 30 Aug 2002 10:26:10 -0700, "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp> said:

  >> Compie fails at arch/ia64/kernel/init_task.c when I use
  >> RedHat's gcc 2.96.
  >> Is this time to consider gcc3.x as a default compiler for ia64?

Well, I'm not sure I'd go that far.  Even gcc3.1 crashed for me at
some point (I think it was on ide-floppy.c).  I haven't had time to
look into this one yet.  Perhaps gcc-3.2 has this fixed already.

If someone sends me a patch to make things compile with gcc 2.96, I'll
certainly apply it (assuming it's a reasonable patch).  I just don't
use gcc 2.96 myself anymore.

	--david

