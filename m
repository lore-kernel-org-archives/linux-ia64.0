From: Keith Owens <kaos@sgi.com>
Date: Fri, 11 Feb 2005 07:33:13 +0000
Subject: Re: [patch 2.6.11-rc3-bk4] Correctly dereference ia64_mca_data
Message-Id: <17638.1108107193@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <23464.1107851114@kao2.melbourne.sgi.com>
In-Reply-To: <23464.1107851114@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 10 Feb 2005 22:57:08 -0800, 
"Luck, Tony" <tony.luck@intel.com> wrote:
>I've established that the scratch FP registers need to be saved, but
>nobody is doing that.
>
>Attached (untested) patch does that (not paticularly elegantly, but
>should be functional).

As davidm has pointed out, if the OS MCA handler saves the scratch and
preserved registers before calling C and restores the values before
returning to SAL then we have no problems.  By definition, the only
registers that matter are those in struct pt_regs.  Think of an MCA as
just another type of interrupt, with exactly the same requirements for
saving registers.

I am completely dropping the proc_state_dump data area and 90% of the
code in os_mca_dump/restore.  Instead of saving everything in sight, I
create a struct pt_regs from the current registers plus some data from
the min_state_save area.  That has three benefits - it gets rid of the
special case RSE stack frame, it gives a real pt_regs for unwinding
through the MCA handler and it guarantees that we save the required set
of registers.

Work in progress, I should have a patch by Monday.

