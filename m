From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 08 Feb 2010 19:21:33 +0000
Subject: RE: binfmt_elf32 / compat_binfmt_elf.c
Message-Id: <987664A83D2D224EAE907B061CE93D5311FEB491@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100205153253.GA24644@infradead.org>
In-Reply-To: <20100205153253.GA24644@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> It looks like IA64 still has it's own binfmt_elf32.c instead of using
> the generic fs/compat_binfmt_elf.c which is used by other architectures
> that have the regset infrastucture.  Any good reason for skipping that
> part of the conversion?

What if I just remove it, along with the rest of CONFIG_IA32 support?
Nobody uses this code any more.

-Tony
