From: Russ Anderson <rja@sgi.com>
Date: Wed, 27 Feb 2008 16:29:08 +0000
Subject: Re: ia64_mca_cpe_int_handler
Message-Id: <20080227162908.GA1908@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 27, 2008 at 04:53:32AM -0600, Robin Holt wrote:
> 
> Russ, do you know what the max number of MCA/INIT records we would
> expect to see during a worst-case type event?

At least NR_CPUS.  In the case of an nmi of the systen, for example, there
will be an INIT record for each CPU.  SAL is expected to create a record
for each CPU.

I think the real question is how many MCA/INIT records will linux 
process at one time.  For both MCA and INIT, the CPUs are rendezvoused
one CPU becomes the monarch, so there is only one CPU calling down to 
SAL at a time.  Even in the case of multiple CPUs going into MCA at
the same time the handling is done one CPU at a time (after the first
CPU handles its MCA it is demoted to a slave and the next CPUs promoted
to monarch to handle its MCA).  

That said, the more parallel the processing of records, the more buffering
will be needed.  

There is the potential for nested MCAs one a given CPU that should be
handled.  Since CPUs are rendezvoued, it is extremely unlikely to have
more that one layer of nesting (two MCA records).  

Nested CPEI/CMCI are more likely.  Since the handling of those interrupts
is done with interrupts enabled (per the MCA Spec) there is a greater
potential for multiple records per CPU being processed at the same
time.

A big part of the issue is how quickly salinfo able to process records.
The quicker it handles the records, the less buffering is needed.
Since salinfo is running in userland, it can get held off for long
periods of time.

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
