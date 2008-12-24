From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 24 Dec 2008 21:50:50 +0000
Subject: Re: [PATCH 5/5] IA64 dynamic ftrace support
Message-Id: <13196.1230155450@ocs14w>
List-Id: <linux-ia64.vger.kernel.org>
References: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
In-Reply-To: <1230012500.10933.102.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 24 Dec 2008 08:29:05 -0500, 
Steven Rostedt <srostedt@redhat.com> wrote:
>Yes I understand that the module and kernel code is set up differently,
>PPC is pretty much the same in this aspect. I'm asking if it is easy to
>change a call from the module to kernel core to another function in
>kernel core?
>
>Question: if I have a call from the module to _mcount, how much has to
>change in the set up of the registers to make it call ftrace_call
>instead?  Perhaps we could link in a call to ftrace_call via the tricks
>in recordmcount.pl to get the info needed to make that change?

The IA64 kernel uses the same gp register throughout, it is compiled
with -mconstant-gp.  So changing the target address from one kernel
function to another only requires changing the destination address in
the PLT stub, no other registers are affected.

