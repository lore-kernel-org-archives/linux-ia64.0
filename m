From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 26 Apr 2004 22:14:54 +0000
Subject: Re: [RFC IA64 Hotplug] [Patch 4/7] hotcpu_ia64.patch
Message-Id: <16525.35294.807376.193745@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ORSMSX4041XvpFVjCRG0000016f@orsmsx404.amr.corp.intel.com>
In-Reply-To: <ORSMSX4041XvpFVjCRG0000016f@orsmsx404.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some general comments on this patch:

 - Please keep the #include list alphabetically sorted (at least in
   the ia64-specific files).  Doing so not only makes it easier to
   find the right include, but it also tends to expose implicit &
   broken include-dependendencies.

 - Please don't mangle whitespace unnecessarily (e.g., don't
   add/delete whitespace in code that you don't change otherwise).

 - There appear to be testing/workaround-hacks in play_dead().  I
   assume you're working on resolving those.

 - Don't initialize global variables explicitly with zeros.  That
   happens automatically (and with older compilers, it will needlessly
   inflate the size of the data area).

 - I really dislike it when function pointers are invoked without
   explicit dereferencing.  I know that other Linux kernel developers
   disagree, but I'd appreciate it if we could at least try to keep
   the ia64-code clean in that way.  Please use (*foo)(args) instead
   of foo(args).  Transparency is one of the nicer features of C,
   let's take advantage of that!

Thanks,

	--david
