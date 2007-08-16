From: Thomas Renninger <trenn@suse.de>
Date: Thu, 16 Aug 2007 14:27:15 +0000
Subject: RE: scripts/mod/file2alias.c cross compile problem
Message-Id: <1187274435.8780.780.camel@queen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2A0211AFF0@scsmsx411.amr.corp.intel.com>
	 <1186092501.6131.154.camel@localhost.localdomain>
In-Reply-To: <1186092501.6131.154.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Luck, Tony" <tony.luck@intel.com>, Adrian Bunk <bunk@stusta.de>, Sam Ravnborg <sam@ravnborg.org>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Fri, 2007-08-03 at 08:08 +1000, Rusty Russell wrote:
> On Thu, 2007-08-02 at 09:25 -0700, Luck, Tony wrote:
> > > Adrian Bunk: scripts/mod/file2alias.c is compiled with HOSTCC and ensures that
> > > kernel_ulong_t is correct, but it can't cope with different padding on
> > > different architectures.
> > 
> > Surely this is the root cause ... you can't expect that the alignment
> > rules of HOSTCC to make any sense for an arbitraty target.
> > 
> > > +#define FILLUP_LEN	7 /* dirty fix for i386 -> 64bit cross-compilation */
> > >  
> > >  struct acpi_device_id {
> > >  	__u8 id[ACPI_ID_LEN];
> > > +	__u8 dummy[FILLUP_LEN];
> > >  	kernel_ulong_t driver_data;
> > >  };
> > 
> > What's so special about this structure that we get an error?
> 
> It's in mod_devicetable.h: see comment at top of that file.  These
> structures serve dual purpose: to describe the capabilities of the
> driver to the kernel probing functions, *and* to export them to
> userspace tables.  The former purpose is why there's a data pointer in
> there.
> 
> scripts/mod/file2alias is the program that reads this: although it can
> be altered to parse 32-vs-64, Adrian's fix is the simplest.

Oops, this will cause a lot build warnings, as this struct gets
initialized like that:
        ..
        {"PNP0C0A", 0},
        ..
at a lot places. It would be better to bump up the id itself like the
attached patch does...

Thanks,

    Thomas

----------------------

Cross-compilation between e.g. i386 -> 64bit could break -> work around it

Adrian Bunk: scripts/mod/file2alias.c is compiled with HOSTCC and ensures that
kernel_ulong_t is correct, but it can't cope with different padding on
different architectures.

Signed-off-by: Thomas Renninger <trenn@suse.de>

---
 include/linux/mod_devicetable.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.23-rc3/include/linux/mod_devicetable.h
=================================--- linux-2.6.23-rc3.orig/include/linux/mod_devicetable.h
+++ linux-2.6.23-rc3/include/linux/mod_devicetable.h
@@ -159,7 +159,8 @@ struct ap_device_id {
 
 #define AP_DEVICE_ID_MATCH_DEVICE_TYPE		0x01
 
-#define ACPI_ID_LEN	9
+#define ACPI_ID_LEN	16 /* only 9 bytes needed here, 16 bytes are used */
+			   /* to workaround crosscompile issues */
 
 struct acpi_device_id {
 	__u8 id[ACPI_ID_LEN];


