From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 06 Jun 2005 17:06:28 +0000
Subject: Re: [patch 2.6.12-rc5] Module gp must point to valid memory
Message-Id: <17060.33428.446753.641603@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7136.1118048668@kao2.melbourne.sgi.com>
In-Reply-To: <7136.1118048668@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 06 Jun 2005 19:04:28 +1000, Keith Owens <kaos@sgi.com> said:

  Keith> Some bits of the kernel assume that gp always points to valid memory,
  Keith> in particular PHYSICAL_MODE_ENTER() assumes that both gp and sp are
  Keith> valid virtual addresses with associated physical pages.

Ah, another "fun" issue caused by putting the text in region 5...

I think the real issue are the "tpa" instructions.  For those to work,
there must be a valid va -> pa translation.  It's not like the memory
that gp points to is every accessed.

The patch looks fine to me.

	--david
