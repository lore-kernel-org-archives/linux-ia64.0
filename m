From: "Niels Christiansen" <nchr@us.ibm.com>
Date: Wed, 30 Jan 2002 06:26:31 +0000
Subject: Re: [Linux-ia64] What's taking all the system time..?
Message-Id: <marc-linux-ia64-105590698805952@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805950@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805950@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> You can grab the source (18kB) here:
>
> http://www.idesign.fl.net.au/why_systime/why_systime.tar.gz
>
> just 'make' (be sure 'gcc' and 'g++' point to a recent enough
> version of gcc/g++ - preferably 3.0 or later) and then run 'a.out'.

I tried using gcc 3.0.2 on a RedHat 7.2 4-way with 2.4.16 kernel
but got errors as shown below.  I have a profiling tool (currently
internal use only) which I intended to use but I need the make to
succeed first...

You say you run on an SMP.  How many processors?

... Niels

-------------------------------------------------------------------

[nchris@tollway why_systime]$ make
gcc -c mt19937b-int.c
g++ Graph.cpp bench.cpp mt19937b-int.o
In file included from BlockTree.cpp:17,
                 from Graph.h:7,
                 from Graph.cpp:2:
BlockTree.h:121:8: warning: extra tokens at end of #endif directive
/tmp/ccC11dFe.s: Assembler messages:
/tmp/ccC11dFe.s:15538: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI4Edge4DCSOE10AddNewPageEv#)'
/tmp/ccC11dFe.s:15539: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI4Edge4DCSOE10RemovePageEPNS_17ResourceCachePageE#)'
/tmp/ccC11dFe.s:15548: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI6Vertex4DCSOE10AddNewPageEv#)'
/tmp/ccC11dFe.s:15549: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI6Vertex4DCSOE10RemovePageEPNS_17ResourceCachePageE#)'
/tmp/ccC11dFe.s:15558: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic11MemoryCacheI4DCSOE10AddNewPageEv#)'
/tmp/ccC11dFe.s:15559: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic11MemoryCacheI4DCSOE10RemovePageEPNS_17ResourceCachePageE#)'
In file included from BlockTree.cpp:17,
                 from Graph.h:7,
                 from bench.cpp:3:
BlockTree.h:121:8: warning: extra tokens at end of #endif directive
/tmp/ccC11dFe.s: Assembler messages:
/tmp/ccC11dFe.s:3233: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI4Edge4DCSOE10AddNewPageEv#)'
/tmp/ccC11dFe.s:3234: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI4Edge4DCSOE10RemovePageEPNS_17ResourceCachePageE#)'
/tmp/ccC11dFe.s:3243: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI6Vertex4DCSOE10AddNewPageEv#)'
/tmp/ccC11dFe.s:3244: Error: Unknown opcode `data16.ua @iplt
(_ZN5basic13ResourceCacheI6Vertex4DCSOE10RemovePageEPNS_17ResourceCachePageE#)'
make: *** [default] Error 1
[nchris@tollway why_systime]$. gcc -v
Reading specs from /usr/lib/gcc-lib/ia64-unknown-linux/3.0.2/specs
Configured with: /usr/src/gcc-3.0.2/configure --prefix /usr --mandir
/usr/share/man
Thread model: single
gcc version 3.0.2
[nchris@tollway why_systime]$ g++ -v
Reading specs from /usr/lib/gcc-lib/ia64-unknown-linux/3.0.2/specs
Configured with: /usr/src/gcc-3.0.2/configure --prefix /usr --mandir
/usr/share/man
Thread model: single
gcc version 3.0.2
[nchris@tollway why_systime]$


