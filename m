From: Jim Wilson <wilson@cygnus.com>
Date: Thu, 23 Nov 2000 19:47:28 +0000
Subject: Re: [Linux-ia64] -ma-step and -mconstant-gp options for gcc?
Message-Id: <marc-linux-ia64-105590678205772@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205770@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205770@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The -ma-step option enables compiler workarounds for A-step and B0-step
errata.  So far it didn't seem worth the trouble to add a -mb0-step option.
This option will likely be removed before the next toolchain release.

There is also a -mb-step option that enables compiler workarounds for B-step
errata.  This should be used if compiling code for B-step machines.  -ma-step
implies -mb-step, so you don't need both.

For -mconstant-gp, see the discussion of the elf header flag EF_IA_64_CONS_GP
in the psABI.

Jim

