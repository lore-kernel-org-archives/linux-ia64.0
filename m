From: Hugo Kohmann <hugo@dolphinics.no>
Date: Wed, 03 Mar 2004 15:12:33 +0000
Subject: Re: [Linux-ia64] Re: Status on ioremap patch
Message-Id: <Pine.LNX.4.44.0403031552050.17420-100000@boss.dolphinics.no>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Hi,

Is there any news or progress for official support for setting up kernel 
space write-combine mappings for Itanium systems. ?? Steffens patch is a 
good start, but we would like to avoid patching the kernel.

We are currently implementing a kernel space socket module for SCI 
(bypassing the TCP/IP protocols). Typical latency for send/receive 
between two systems is down to 2.7us for small messages ( Benchmarks 
running on Opterons ). Without kernel write-combine we would need to use 
regular DMA to move data, and we would no longer get the 2.7us latency.

Linux running on both IA32 and X86_64 systems supports some kind of kernel 
write-combine, why not IA64 ??

Best regards

Hugo



>>>>>> On Wed, 09 Jan 2002 21:01:13 +0100, Steffen Persvold <sp@scali.no> 
>said:
>
>  Steffen> So, what about this patch (posted earlier) David ? Have you
>  Steffen> seen the comments from Keith ?
>
>Keith's concerns are legitimate and to some degree apply even for
>ia64.  On ia64, we need to be careful to avoid mapping the same
>physical page with different memory attributes.  If more and more
>drivers are starting to use write-combine mappings, we need to solve
>this problem properly.  I don't have a solution off hand (I suspect
>we'll have to keep track of which i/o regions are mapped how) and
>don't have time to work on it now.  I'd recommend to maintain a
>separate patch for now, until a proper solution is ready (which will
>have to take non-ia64 platforms into consideration, of course).
>
>	--david
>
>PS: I apologize for not being as responsive yet as I'd like to be.
>    I'm done with the book (well, 99.999% as my wife put it...) and
>    ready to attack my backlog of kernel work (and other things, such
>    as user-level unwind support).  I just had a spell of bad luck
>    this week, which didn't help.  Hopefully, over the next one or two
>    weeks, things will start to go back to normal.




-- 

============================================Hugo Kohmann                           |
Dolphin Interconnect Solutions AS      | E-mail:
P.O. Box 150 Oppsal                    | hugo@dolphinics.com
N-0619 Oslo, Norway                    | Web:
Tel:+47 23 16 71 73                    | http://www.dolphinics.com
Fax:+47 23 16 71 80                    | Home Office:
Visiting Address: Olaf Helsets vei 6   | Tel: +47 22 23 25 35

