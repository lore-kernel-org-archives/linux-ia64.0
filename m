From: Christoph Lameter <clameter@sgi.com>
Date: Thu, 03 Mar 2005 05:19:31 +0000
Subject: Re: Page fault scalability patch V18: Drop first acquisition of ptl
Message-Id: <Pine.LNX.4.58.0503022117450.4083@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0503011947001.25441@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0503011951100.25441@schroedinger.engr.sgi.com>
 <20050302174507.7991af94.akpm@osdl.org> <Pine.LNX.4.58.0503021803510.3080@schroedinger.engr.sgi.com>
 <20050302185508.4cd2f618.akpm@osdl.org> <Pine.LNX.4.58.0503021856380.3365@schroedinger.engr.sgi.com>
 <20050302201425.2b994195.akpm@osdl.org> <16934.39386.686708.768378@cargo.ozlabs.ibm.com>
In-Reply-To: <16934.39386.686708.768378@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Paul Mackerras <paulus@samba.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, benh@kernel.crashing.org, anton@samba.org

On Thu, 3 Mar 2005, Paul Mackerras wrote:

> More generally, I would be interested to know what sorts of
> applications or benchmarks show scalability problems on large machines
> due to contention on mm->page_table_lock.

Number crunching apps that use vast amounts of memory through MPI or
large databases etc. They stall for a long time during their
initialization phase without these patches.
