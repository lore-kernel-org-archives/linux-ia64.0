From: Omar Stradella <omar@sgi.com>
Date: Tue, 02 May 2000 22:20:28 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205067@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 2 May 2000, Jim Wilson wrote:

> There is an optional patch in the list archives that adds support to the
> linker for handling out of range calls.  At the moment, it requires that the
> user manually specify -Wl,-relax.  You might try using that option to see if
> your toolchain already has the patch applied.  If not, then you can patch
> your toolchain, rebuild it, and this problem should go away.
> 
> Eventually we will have better support for large programs.  That may include
> changing some of the start up code to avoid some of the problems that you are
> seeing.

Jim,

Thanks, that seems to work. Except that the kernel that I'm running 
(2.3.99-pre5-000424-17) doesn't seem to support the brl instruction yet.

Omar.
+---------------------------------------------------------------------+
Omar G. Stradella, Ph.D.                    
SGI / Chemistry and Biology Applications Group
1 Cabot Rd, Suite 250, Hudson, MA 01749, USA    N 42 22'40" W 71 33'44"
E-mail: omar@sgi.com        Phone: +1-781-839-2258 FAX: +1-978-562-7450 
http://www.sgi.com/chembio                  http://reality.sgi.com/omar 
+--------  Ph-nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn  -------+



