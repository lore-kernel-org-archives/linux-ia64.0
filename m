From: Michael Raymond <mraymond@sgi.com>
Date: Tue, 22 Feb 2005 16:59:57 +0000
Subject: User Level I/O
Message-Id: <20050222105957.B67472@goliath.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

    Some embedded and I/O intensive applications prefer to do most of their
I/O processing work in user space.  They can do this through PIOs and
mmap'ing their device registers.  I'd like to present a feature that will
allow them to handle interrupts in user space as well.
    SGI's User Level Interrupt (ULI) feature allows applications to safely
do interrupt processing with user space handler functions.  Applications get
a high degree of control and a quick response (~3us) while ensuring that
things like segfaults or infinite loops in the handler won't take down the
OS.  More information can be found at http://oss.sgi.com/projects/uli/.
    I have ULI patches for IA64 on 2.6.10 and 2.6.11-rc4.  On the web page
you can also find a support library, documentation, and very simple sample
applications.  The feature definitely isn't done yet but it's ready for
people to start playing with.  In particular, the code for handling infinite
loops and supporting debugging is incomplete and the assembly needs to be
cleaned up.
    Please take a look at this and let me know what you guys think.  We'd
like to get this integrated in 6.5.12 or soon after.
     	    	 	       	      	      	    Thanks,
						    	   Michael
-- 
Michael A. Raymond              Office: (651) 683-3434
Core OS Group                   Real-Time System Software
