From: <dhruv.anand@wipro.com>
Date: Mon, 01 Mar 2004 14:54:50 +0000
Subject: Boot param 'mem' with relocated kernel.
Message-Id: <CC7A2BA2F1CA9E43B2B62C4783B42C7BE2E7D5@blr-ec-msg05.wipro.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi, 

I am trying to load 2.6.1 kernel at 1MB. The  kernel size is 3.6M. 
The page granularity is set to 16Mb for the kernel.  I need to restrict
the memory usage of this kernel. I am trying to do this by using the 
"mem=XXXM" boot parameter. This does not work, and results in a kernel 
panic with the message "Killing idle task" and another panic with
message 
"killing interrupt handler".

The same works fine for a normal kernel(without relocation).

As an alternative, I tried restricting memory by calling the
reserve_bootmem()
function. This works fine.

Is there any dependency of the 'mem' parameter on a relocated kernel?
Have I missed out something ? 

Regards
Dhruv.

