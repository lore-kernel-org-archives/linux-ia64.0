From: Omar Stradella <omar@sgi.com>
Date: Tue, 02 May 2000 21:36:28 +0000
Subject: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205064@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm trying to build a large program but the executable coredumps in
_start. The reason is that _start (start.S) calls __libc_start_main using
a IP-relative call instruction. libc is inserted after all the object
files at an address that is more than 16MB away from the call instruction.
Same happens in _init (initfini.c). Could be possible to load the address
in a register and do an indirect call instead ?

Thanks,

Omar.
+---------------------------------------------------------------------+
Omar G. Stradella, Ph.D.                    
SGI / Chemistry and Biology Applications Group
1 Cabot Rd, Suite 250, Hudson, MA 01749, USA    N 42 22'40" W 71 33'44"
E-mail: omar@sgi.com        Phone: +1-781-839-2258 FAX: +1-978-562-7450 
http://www.sgi.com/chembio                  http://reality.sgi.com/omar 
+--------  Ph-nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn  -------+




