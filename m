From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 10 Mar 2006 17:22:37 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <200603101722.k2AHMag04717@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Zoltan Menyhart wrote on Friday, March 10, 2006 1:47 AM
> > CPU A        CPU B       | CPU A       CPU B     | cpu A    cpu B
> > -----        -----       | -----       -----     | -----    -----
> >              change pte  |                       |
> >                          |                       |
> > read pte                 |read pte               |read pte
> > insert TLB               |           change pte  |insert
> > re-read                  |insert                 |re-read
> >                          |re-read                |          change pte
> >                          |ptc.l
> 
> These scenarii assume that the sequence:
> 
> 	insert TLB
> 	;;
> 	re-read
> 
> is executed in the same order for everyone as it is coded.

Just for the record, itc has acquire semantics, though this is not
immediately relevant in this discussion with respect to external
ptc.g.

- Ken

