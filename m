From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Jul 2002 16:28:14 +0000
Subject: Re: [Linux-ia64] kernel update (relative to v2.4.18)
Message-Id: <marc-linux-ia64-105590701905820@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 23 Jul 2002 15:58:58 +1000, Keith Owens <kaos@ocs.com.au> said:

  Keith> I agree, but given the restrictions of CML1, there is no
  Keith> choice.  The problem is not just xconfig, it affects
  Keith> menuconfig as well.  Before this patch, arch/ia64/config.in
  Keith> set DEVFS=y for SN[12] but there was nothing stopping a user
  Keith> changing DEVFS in the fs menu.  Other cross menu dependencies
  Keith> have the same problem with any config system that allows out
  Keith> of order evaluation.

  Keith> CML1 does _not_ enforce dependencies across menus, the
  Keith> dependencies have to be in a single menu.  This was one of
  Keith> the driving forces behind CML2, to get some method for doing
  Keith> cross menu constraints.  Without CML2, we have to scatter
  Keith> arch dependent code over generic config menus :(.

I see your point about DEVFS, but the simulator part should be OK.  In
that case, we never even include drivers/ide/Config.in.

	--david

