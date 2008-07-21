From: Russ Anderson <rja@sgi.com>
Date: Mon, 21 Jul 2008 19:45:43 +0000
Subject: Re: [PATCH 0/2] Migrate data off physical pages with corrected memory errors (Version 7)
Message-Id: <20080721194543.GA214920@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080718203514.GD29621@sgi.com> <87prpa88iw.fsf@basil.nowhere.org> <20080720173914.GA9409@sgi.com> <1216667499.8806.79.camel@lappy>
In-Reply-To: <1216667499.8806.79.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Williamson <alex.williamson@hp.com>
Cc: Andi Kleen <andi@firstfloor.org>, mingo@elte.hu, tglx@linutronix.de, Tony Luck <tony.luck@intel.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Mon, Jul 21, 2008 at 01:11:39PM -0600, Alex Williamson wrote:
> On Sun, 2008-07-20 at 12:39 -0500, Russ Anderson wrote:
> > On Sat, Jul 19, 2008 at 12:37:11PM +0200, Andi Kleen wrote:
> > > If you really wanted to do this you probably should hook it up
> > > to mcelog's (or the IA64 equivalent) DIMM database
> > 
> > Is there an IA64 equivalent?  I've looked at the x86_64 mcelog,
> > but have not found a IA64 version.
> 
> There's a bit in the SAL error record that can tell you when the
> platform thinks the page should be deallocated.  In the section header
> (B2.2), ERROR_RECOVERY_INFO, bit 3 "Error threshold exceeded".  If you
> use this bit, then it's a platform decision.  If you want pages to be
> deallocated on the first hit, then have your SAL always set that bit.  I
> believe HP systems do implement this bit in SAL using some kind of
> heuristics.

Good point.  Linux does not have that field defined.

I'll submit a real patch to Tony shortly.
-------------------------------------------------
---
 include/asm-ia64/sal.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linus/include/asm-ia64/sal.h
=================================--- linus.orig/include/asm-ia64/sal.h	2008-07-18 11:32:02.000000000 -0500
+++ linus/include/asm-ia64/sal.h	2008-07-21 14:40:47.142922279 -0500
@@ -341,7 +341,8 @@ typedef struct sal_log_record_header {
 typedef struct sal_log_sec_header {
     efi_guid_t guid;			/* Unique Section ID */
     sal_log_revision_t revision;	/* Major and Minor revision of Section */
-    u16 reserved;
+    u8 error_recovery_info;		/* Platform error recovery status */
+    u8 reserved;
     u32 len;				/* Section length */
 } sal_log_section_hdr_t;
 

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
