From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 16 May 2003 22:58:31 +0000
Subject: Re: [Linux-ia64] RE: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705917@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 16 May 2003 15:54:27 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> It's the wrong file ... that's from last November ... it just
  Tony> happened to be in the folder on my PC where I dump things to
  Tony> attach to e-mail. I meant to pick up the kcore.diff (now
  Tony> attached).

Ah, I see.

Definitely something to be discussed on the lkml.  I suspect it would
be better to avoid creating the PT_NULL header when it's not needed.

	--david

