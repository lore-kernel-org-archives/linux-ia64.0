From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 22 Feb 2008 22:32:11 +0000
Subject: RE: ia64_mca_cpe_int_handler
Message-Id: <1FE6DD409037234FAB833C420AA843ECA4220D@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <47BF02EC.4080102@bull.net>
In-Reply-To: <47BF02EC.4080102@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> I think the interrupts are enabled too early.

This looks reasonable ... enabling the interrupts in code
where we will hold the cmc_history_lock (or the cpe_history_lock)
looks like a recipe for problems.

> Please have a look at this patch.

+	if (irq_safe){
+		/* SAL spec states this should run w/ interrupts enabled */
+		local_irq_enable();
+	}

On first reading this I was a bit worried that you didn't enable
interrrupts for *all* calls to SAL_GET_STATE_INFO calls (and
rather worried that we perhaps needed to for MCA ... which sounded
like a very, very bad idea).  But I went back to re-read the SAL
spec, and figured out my confusion.

The "irq_safe" variable is being over-loaded with extra meaning
here ... it has the value we want (true for CMC or CPE) but the
comment about SAL spec doesn't quite match the "irq safe" meaning
implied by the name of the variable.

The SAL spec doesn't say that we must have interrupts enabled if
it is safe to do so, it says: "The operating system-corrected
error handler shall run with interrupts enabled".

Perhaps just update the comment to:

		/* SAL spec says CMC and CPE handler must enable interrupts */

which at least points the reader a little more clearly to what is
going on.  Either that or make the test:

	if (sal_info_type = SAL_INFO_TYPE_CMC || sal_info_type = SAL_INFO_TYPE_CPE) {
		/* SAL spec states these should run w/ interrupts enabled */

[This looks way too verbose]

-Tony
