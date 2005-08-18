From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Thu, 18 Aug 2005 15:15:46 +0000
Subject: Re: Looking for MCA/INIT register test program
Message-Id: <200508181515.j7IFFkqd2069696@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5289.1124337382@kao2.melbourne.sgi.com>
In-Reply-To: <5289.1124337382@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >I have a dim, distant memory that somebody (Tony Luck?) wrote a program
> >that loaded all the registers, generated a recoverable MCA or INIT then
> >verified that the registers still matched.  Google did not find it.
> >Any pointers?
> 
> I wrote a program that sounds a lot like that.  It does the bit
> about saving registers, and checking them.  But it is left as
> an exercise for the user to generate the MCA.

The Altix memory error injection program is good a creating MCAs.
Started running it with Keith's new patch.  It's worked so far,
with no obvious regressions.  Testing continues...

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
