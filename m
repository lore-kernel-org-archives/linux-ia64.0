From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 03 Feb 2003 19:34:40 +0000
Subject: Re: [Linux-ia64] [PATCH] IA32 support without sysctl doesn't work
Message-Id: <marc-linux-ia64-105590709805800@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805797@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805797@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 3 Feb 2003 09:54:11 +1100, Peter Chubb <peter@chubb.wattle.id.au> said:

  Peter> If you try to compile with CONFIG_IA32 on and CONFIG_SYSCTL off, then
  Peter> you get an undefined reference to do_sysctl() on final link.

  Peter> I believe that if sysctl is turned off, it should be off for IA32
  Peter> processes as well as for IA64 processes.

Agreed.

  Peter> Here's a patch:

The ia32 subsystem should mirror what's done in kernel/sysctl.c: when
CONFIG_SYSCTL isn't defined, there should be a dummy sys32_sysctl().
That way, the number of #ifdefs is localized to one file.

	--david

