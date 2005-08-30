From: Christoph Lameter <clameter@engr.sgi.com>
Date: Tue, 30 Aug 2005 03:28:28 +0000
Subject: Re: [PATCH] Only process_die notifier in ia64_do_page_fault if
Message-Id: <Pine.LNX.4.62.0508292026460.10009@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508262246.j7QMkEoT013490@linux.jf.intel.com>
 <Pine.LNX.4.62.0508261559450.17433@schroedinger.engr.sgi.com>
 <200508270224.26423.ak@suse.de> <20050830001905.GA18279@linux.jf.intel.com>
In-Reply-To: <20050830001905.GA18279@linux.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Lynch <rusty@linux.intel.com>
Cc: Andi Kleen <ak@suse.de>, Rusty Lynch <rusty.lynch@intel.com>, linux-mm@kvack.org, prasanna@in.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, anil.s.keshavamurthy@intel.com

On Mon, 29 Aug 2005, Rusty Lynch wrote:

> So, assuming inlining the notifier_call_chain would address Christoph's
> conserns, is the following patch something like what you are sugesting?  
> This would make all the kdebug.h::notify_die() calls use the inline version. 

Please do not generate any code if the feature cannot ever be 
used (CONFIG_KPROBES off). With this patch we still have lots of 
unnecessary code being executed on each page fault.
