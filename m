From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 28 May 2003 22:37:31 +0000
Subject: Re: [Linux-ia64] [PATCH] MCA recovery for TLB faults for 2.4
Message-Id: <marc-linux-ia64-105590723706059@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 28 May 2003 13:35:53 -0700, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>The underlying algorithm is to save information about what
>each of the ITR/DTR registers is mapping, then at MCA time
>we can purge the whole TLB (TC and TR) and reload the TR
>registers before jumping to virtual mode.

ia64_os_mca_tlb_purge_and_reload() will break if somebody compiles the
kernel with -pg, say for profiling or stack monitoring.  -pg adds a
call to mcount() at the start of every function and mcount expects to
run in virtual mode.  kdb has the same problem, I get around it by
adding this line to the Makefile.

override CFLAGS := $(CFLAGS:%-pg=% )

That affects all objects in the directory, we do not want to apply that
to all objects in arch/ia64/kernel, we do not even want to apply it to
all functions in mca.c.  Please move ia64_os_mca_tlb_purge_and_reload()
to its own source file in a sub directory, say arch/ia64/kernel/physical.


