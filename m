From: Gustavo Niemeyer <niemeyer@conectiva.com>
Date: Thu, 03 May 2001 17:37:53 +0000
Subject: [Linux-ia64] HP Simulator & Kernel 2.4.3
Message-Id: <marc-linux-ia64-105590693005529@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello!

I'm trying to make the hp simulator work with kernel 2.4.3. Is
that possible, or the simulator has been left out for a long time?

After successfully compiling the kernel (one little patch was needed),
I've got these messages while trying to boot the kernel with ski:

[...]
kernel BUG at bootmem.c:144!
swapper[0]: General Exception: IA-64 Reserved Register/Field fault (data
access) 549755813936
[...]

The second message repeats until the kernel panics with:

[...]
Call Trace: [<e00000000441db80>] sp=0xe0000000046dd080
bsp=0xe0000000046dedd0
Kernel panic: Attempted to kill the idle task!
In idle task - not syncing

Maybe I'm using some option I shouldn't...

If there's no way of working out those problems, anybody knows what's
the latest kernel that works with the simulator?

Thanks!!

-- 
Gustavo Niemeyer

[ 2AAC 7928 0FBF 0299 5EB5  60E2 2253 B29A 6664 3A0C ]

