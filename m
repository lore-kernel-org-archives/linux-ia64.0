From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 12 Nov 2002 18:23:21 +0000
Subject: Re: [Linux-ia64] gdb'ing 32-bit executable on IA64
Message-Id: <marc-linux-ia64-105590709805404@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 12 Nov 2002 10:34:46 -0700, Don Dugger <n0ano@n0ano.com> said:

  Don> David- Nope, that didn't work.  I'm running a 2.4.18 kernel,
  Don> the EMUL_PREFIX_LINUX_IA32 is set to `emul/ia32-linux/', I put
  Don> the IA32 version of `sh' into `/emul/ia32-linux/bin/sh' and the
  Don> IA32 `gdb' didn't work.  Do you think this is something we need
  Don> to worry about or is it just a quirk of `gdb'?

Hmmh, to be honest, I always have used gdb.x86 without doing anything
special about the shell and it always worked for me.  Perhaps we're
using different gdb versions or we're doing something differently?  I
seem to be using "gdb 5.0rh-5" from x86 Red Hat 7.1.

	--david

