From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 09 Mar 2006 19:44:51 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <200603091944.k29Jing23926@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Christoph Lameter wrote on Thursday, March 09, 2006 10:28 AM
> On Thu, 9 Mar 2006, Zoltan Menyhart wrote:
> > In short: unless we use "srlz.d", how to make sure:
> > - the visibility of the "itc" instruction to generated purges is
> >   guaranteed first
> > - issuing "ld" goes after ?

Let's go back one step, the guarantee is coming from the fact that
ptc.ga happens after pte change.  And the fault handler guarantees
that by the time 2nd load happens, TLB state is consistent with
what is in the software page table.  It doesn't matter where the
ptc.ga come through.  As long as the TLB state is consistent with
respect to software page table, we are fine.  Considering the
following 3 cases:

CPU A        CPU B       | CPU A       CPU B     | cpu A    cpu B
-----        -----       | -----       -----     | -----    -----
             change pte  |                       |
                         |                       |
read pte                 |read pte               |read pte
insert TLB               |           change pte  |insert
re-read                  |insert                 |re-read
                         |re-read                |          change pte
                         |ptc.l

Global purge doesn't need to come into the picture here.


> I guess this scheme could fail if the remote processor would 
> zap the pte and do the broadcast between the local processors cmpxchg
> and the itc. Thats only two bundles. 

How can that fail?:

cpu A         cpu B
-----         -----
read
cmpxchg
              xchg
              ptc.g
itc
re-read
ptc.l

- Ken

