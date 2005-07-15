From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Fri, 15 Jul 2005 04:52:09 +0000
Subject: RE: [NUMA] Display and modify the memory policy of a process through /proc/<pid>/numa_policy
Message-Id: <200507150452.j6F4q9g10274@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.62.0507141838090.418@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0507141838090.418@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0507141838090.418@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Christoph Lameter' <clameter@engr.sgi.com>, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, pj@sgi.com

Christoph Lameter wrote on Thursday, July 14, 2005 6:40 PM
> This patch adds a new proc entry for each process called "numa_policy".
> 
> If read this file will output a text string describing the memory policy
> for the process.
> A new policy may be written to "numa_policy" in order to change the memory
> policy for the process. The following strings may be written to
> /proc/<pid>/numa_policy:
> 
> Additionally the patch also adds write capability to the "numa_maps". One
> can write a VMA address followed by the policy to that file to change the
> mempolicy of an individual virtual memory area. i.e.

This looks a lot like a back door access to libnuma and numactl capability.
Are you sure libnuma and numactl won't suite your needs?

