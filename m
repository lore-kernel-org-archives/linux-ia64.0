From: david mosberger <dmosberger@gmail.com>
Date: Thu, 01 Sep 2005 04:58:58 +0000
Subject: Re: testing mca/init patch
Message-Id: <ed5aea430508312158755646b7@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
In-Reply-To: <200508312343.j7VNhFOZ012157@agluck-lia64.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith,

I took a closer look at your patch set and, by and large, I like it a
lot.  I suppose there will be more debate as to whether treating
MCA/INIT events as an asynchronous task-switch is the right way to go
about it, but so far it looks to me that it does indeed simplify a lot
while creating only a managable set of new headaches.  I guess a key
point is whether or not the generic scheduler mods will be accepted...

Some other points:

- In several places there are checks of the form:

+ if ((r12 & -KERNEL_STACK_SIZE) != r13) {

  I don't understand why you're doing this.  You should check for (r12
- r13) <  KERNEL_STACK_SIZE.  That does the same without relying on
alignments (which is something we have been careful to avoid in all
other ia64 code).  This should also let you drop the patch to
vmlinux.lds.S.

- In ia64_os_mca_virtual_begin(), I'd suggest to use the idiom:

    .save rp, r0

  to terminate the call-chain.  That should simplify this function.

- I worry about copying machine-state from the MCA/INIT stack to the
"old" (process) stack.  What if an MCA was caused by an ECC error on
that old stack?  Wouldn't this prevent you from recovering from what
might otherwise be a recoverable error?

Thanks,

  --david
--
Mosberger Consulting LLC, voice/fax: 510-744-9372,
http://www.mosberger-consulting.com/
35706 Runckel Lane, Fremont, CA 94536
