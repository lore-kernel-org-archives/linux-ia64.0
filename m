From: Zoltan Menyhart <Zoltan.Menyhart_AT_bull.net@nospam.org>
Date: Tue, 18 Nov 2003 15:06:20 +0000
Subject: Re: [RFC] How drivers notice a MCA on I/O read? [1/3]
Message-Id: <marc-linux-ia64-106916801716196@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106915044130197@msgid-missing>
In-Reply-To: <marc-linux-ia64-106915044130197@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Let me make some remarks on I/O triggered MCAs.

Basically, there are 4 kinds of I/Os:
- I/O read / write by CPUs
- I/O read / write by DMAs

1. I/O write by CPUs:

As the machine is pipelined, the writes are executed *much*
later that they leave the CPUs. As soon as the data reaches
an I/O bridge, the I/O is considered to be done for the
coherency domain. O.K. you can wait and make sure that the
written data has reached the I/O device, but you will slow
down by 1000 the I/O access.
An I/O bridge usually does not remember who the originator is,
should an error happen, e.g. PCI PERR / SERR, the bridge does
not know whom to report the error to. It simply issues a
BERR. This is a global MCA, the interrupted context is
not precisely saved. You do not even know e.g. if a
"register++" done just before the MCA arrives,
if it is actually done or not.
You cannot resume the execution, you have to create a
"minimal state" that will be resumed.
And hard luck, the innocent CPUs are also affected, which
do not execute a carefully prepared code to survive an MCA.

2. I/O read by CPUs:

Some I/O bridges may poison the data read, instead of
signaling a BERR.
(Otherwise see above.)
The consummation of poisoned data triggers a local, imprecise
MCA (as above).
Before issuing the critical read (ld.* rx=[ry]) instruction,
make sure no operation is in any of the pipelines (e.g. our
"register++").
Note that the read operation by itself does not consume
the bad data, you have to do something with it, e.g.:

	ld.8	r9=[r10];;	// r10 = I/O address
	add.8	r8=r9,r9;;	// fake operation

An "mf.a" does not help, it is useless, it is an MCA
intern to the CPU.

3. Memory -> DMA -> I/O

Mostly the same as the case 1.
The HW could abort the DMA and the DMA status could indicate
the failure without disturbing the CPUs...
A usual HW simply sends a BERR to everyone :-(

4. I/O -> DMA -> Memory

The HW could abort the DMA, the memory could be poisoned to
indicate to the final consumer the error (CPU local MCA as in
the case 2), and the DMA status could indicate the failure
without disturbing the CPUs...
A usual HW simply sends a BERR to everyone :-(

--------------------------------------------------------------

To cheer you up: a usual machine has got ~ 50.000 hours of
MTBF (including all other errors).
Assuming you have got a sophisticated HW that does not send
unnecessary BERRs, how many errors will be recovered during
the whole life of the machine ?
(You cannot do anything to the imprecise MCA models of the
ia64 architecture).
How much is the MTBF of a Linux ? A well known commercial
unix is estimated to have 6.000 hours. Linux can have ...
Will a not so much reliable SW save the fife of a quite
good HW ?

Zoltan Menyhart
