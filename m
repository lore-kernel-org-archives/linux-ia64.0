From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 11 Nov 2002 19:24:49 +0000
Subject: Re: [Linux-ia64] gdb'ing 32-bit executable on IA64
Message-Id: <marc-linux-ia64-105590709805387@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805292@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805292@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 11 Nov 2002 12:05:27 -0700, Don Dugger <n0ano@n0ano.com> said:

  Don> Nitin- I just remembered, there's one more gotcha you have to
  Don> deal with to run `gdb' on IA32 processes.  `gdb' uses the shell
  Don> to actually execute the target program and, by default, it
  Don> winds up using the IA64 version of the shell.  This doesn't
  Don> work.

  Don> What you have to do is spcify an IA32 shell through the `SHELL'
  Don> environment variable when using the IA32 `gdb'.  If all of the
  Don> IA32 programs are in the directory `/usr/ia32/bin' then the
  Don> following sommand should work:

  Don> 	SHELL=/usr/ia32/bin/sh /usr/ia32/bin/gdb $*

Wouldn't it be much easier to copy the x86 version of bash into

	/emul/ia32-linux/bin/sh

?

	--david

