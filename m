From: Matthew Dobson <colpatch@us.ibm.com>
Date: Tue, 29 Oct 2002 22:19:25 +0000
Subject: [Linux-ia64] Re: [PATCH] topology for ia64
Message-Id: <marc-linux-ia64-105590709805286@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805203@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805203@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Erich Focht wrote:
> On Tuesday 22 October 2002 02:07, David Mosberger wrote:
> 
>>Why does the cpu_to_node_map[] exist for non-NUMA configurations?  It
>>seems to me that it would be better to make cpu_to_node_map a macro
>>that uses an array-check for NUMA configurations and a simple test
>>against phys_cpu_present_map() for non-NUMA.
> 
> Attached is a modified patch for implementing the topology stuff on ia64.
> It's on top of your 2.5.39 tree including acpi_numa and the acpi_numa fix
> which I've sent you separately.
> 
> I dropped the cpu_to_node_map array for the non-NUMA case. The macro
> __cpu_to_node() returns 0 in this case. In the places where it is used
> (e.g. in the NUMA scheduler) we either run on a valid CPU or have
> cpu_online() checks before using it, therefore I also removed the
> phys_cpu_present_map check when building the cpu to node map.

Hi Erich!  Apologies for the long response delay...  I think our mail 
server must be a bit lagged.  ;)

It looks good to me.  As far as this comment:
+/*
+ * Returns the number of the first CPU on Node 'node'.
+ * Slow in the current implementation.
+ * Who needs this?
+ */
+/* #define __node_to_first_cpu(node) pool_cpus[pool_ptr[node]] */
+static inline int __node_to_first_cpu(int node)

No one is using it now.  I think that I will probably deprecate this 
function in the near future as it is pretty useless.  Anyone looking for 
that functionality can just do an __ffs(__node_to_cpu_mask(node)) 
instead, and hope that there is a reasonably quick implementation of 
__node_to_cpu_mask.


> Hope this can be included now...

I agree!  Linus or another maintainer, please pick this up.  These 
macros should be implemented intelligently on as many architectures as 
possible, now that they're beginning to be used in more and more places.

Cheers!

-Matt

> 
> Regards,
> Erich
 >
 > <patch snip>
 >


