From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 23 Oct 2002 19:01:29 +0000
Subject: RE: [Linux-ia64] ia64 compressed makefile target
Message-Id: <marc-linux-ia64-105590709805216@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805211@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805211@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 23 Oct 2002 10:46:32 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> Or perhaps David will take the CONFIG_IA64_VMAP_KERNEL patch
  Tony> that I posted a week ago which also allows the kernel to run
  Tony> on systems without memory at the default link address.
  Tony> Admittedly it's more than one line, but it contains much of
  Tony> the same infrastructure that is needed to support kernel text
  Tony> replication.

I don't have a strong preference either way, but I do have some
concerns about the VMAP_KERNEL.  I really dislike the fact that it
requires different versions of virtual-to-physical translations for
kernel addresses.  No other platform does that, so it will be a source
of continual worry.  Jesse, could you describe your approach a little
more?  I assume you link the kernel with "ld -r" and have an elilo
that applies the relocations?

	--david

