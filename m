From: gjertsen@us.ibm.com
Date: Thu, 16 Nov 2000 20:18:47 +0000
Subject: [Linux-ia64] "unsupported reloc" error with ld
Message-Id: <marc-linux-ia64-105590678205735@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Can a compiler person out there provide some insight
on the following error I get with some C++ code when
doing a final bind with ld:

fs/fs.o(.IA_64.unwind+0x98b8): unsupported reloc
(... a bunch of these ...)

I am trying out the new toolchain from cygnus, 1024 snapshot,
with the old glibc v2.1.3 (and the 2 patches for ABI and shared libs).
This is an improvement from before when I was also getting additional
"Dwarf Error" messages with the current turbolinux toolchain:

--------------------------------------------------------------------------------------------------
ld: Dwarf Error: Could not find abbrev number 100.
(... a bunch more similar to this ...)
fs/fs.o(.IA_64.unwind+0x98d0): unsupported reloc
(... a bunch more similar to this ...)
--------------------------------------------------------------------------------------------------

Based on scaning the IA64 mail lists I saw two notes
that discussed similar looking problems that referred
to C++ EH and the use of inconsistant libraries and toolchain:

[Linux-ia64] Bad unwind record ...   Mon, 24 Jul 2000
[Linux-ia64] ld failure  26 Apr 2000

Thanks,

--Rob



