From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 19 May 2003 18:39:25 +0000
Subject: RE: [Linux-ia64] RE: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705949@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 19 May 2003 10:57:03 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> I've juggled the addresses around again, moving the kernel up to
  Tony> 0xA000004000000000 and VMALLOC_START back down to 0xA000000000030000
  Tony> so that the entry for the kernel goes on the *end* of the vmlist,
  Tony> so we don't have to uselessly step over it on every call to vmalloc().

I don't want the kernel layout to be constrained by something as
esoteric as kcore.  Let's fix kcore for good.

	--david

