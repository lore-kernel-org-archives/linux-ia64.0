From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 18 Apr 2001 18:59:44 +0000
Subject: Re: [Linux-ia64] ia64 emulation
Message-Id: <marc-linux-ia64-105590693005423@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005418@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005418@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is a simulator available from HP as an ia32-linux binary, but it is
not open source.  This isn't ideal, but avoids the need for IA-64 hardware.
	http://www.software.hp.com/ia64linux

See also gdb as an example of a user level program that knows how to single
step other applications.

Some early pre-hardware gdb development was done by running the simulator on
an ia32 machine, booting the ia64 kernel on the simulator, running a gdbserver
process on the kernel, and then connecting to this process over the network
by a cross gdb (ia32-x-ia64).  At that point, you could then run and debug
ia64 applications, same as you can with a native ia64 gdb, though of course
a lot slower.

Jim

