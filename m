From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 05 Jan 2002 05:06:51 +0000
Subject: Re: [Linux-ia64] 2.4.16 + ia64-011128: Unable to execute a "rwx" program
Message-Id: <marc-linux-ia64-105590698805747@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805720@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805720@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>whale% ./prog
>zsh: no such file or directory: ./prog

This usually means that the program specifies an interpreter, and the
interpreter can not be found.

For a shell script, the interpreter is in the first line.  For instance,
if I create a shell script called prog, and put in it two lines
	#!/bin/foo
	exit 0
and then run it, I get the error "bash: ./prog: no such file or directory".
The missing file is "/bin/foo" not "prog".

For an ELF executable, the interpreter is stored in the PT_INTERP field.
"readelf -l prog" will print out the value of the PT_INTERP field along
with a bunch of other stuff.

On my system, readelf -l /usr/bin/zip prints out
  INTERP         0x0000f4 0x080480f4 0x080480f4 0x00013 0x00013 R   0x1
      [Requesting program interpreter: /lib/ld-linux.so.2]

>This is a c++ program I compiled with the Intel compiler.

My guess is that you have an old OS with a new executable, or an old
executable with a new OS, in which case the executable is looking
for different version of ld.so than the one that comes with the OS.

Another possibility is that you are missing one of the libraries that comes
with the Intel compiler.  Or perhaps, you need an environment variable set
before it will work correctly.

Jim

