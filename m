From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 09 Dec 2002 21:14:50 +0000
Subject: [Linux-ia64] Re: ia64 SN update
Message-Id: <marc-linux-ia64-105590709805523@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 9 Dec 2002 13:03:56 -0800, Jesse Barnes <jbarnes@sgi.com> said:

  Jesse> David, here's a patch to update SN support in the ia64 tree.
  Jesse> I had to make a few mods outside arch/ia64/sn and
  Jesse> include/asm-ia64/sn to get CONFIG_IA64_SGI_SN2 to compile.

I applied the patch, except that there were collisions with other
changes to mmzone.h and mca.c.  Could you re-diff after I push out a
new ia64 patch?  (Hopefully today or tomorrow.)

	--david

