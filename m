From: Thomas Renninger <trenn@suse.de>
Date: Thu, 02 Aug 2007 15:09:19 +0000
Subject: Re: scripts/mod/file2alias.c cross compile problem
Message-Id: <1186067359.18821.553.camel@queen.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070727230741.GD15129@stusta.de>
	 <617E1C2C70743745A92448908E030B2A0209BB9D@scsmsx411.amr.corp.intel.com>
	 <20070728013950.GE15129@stusta.de>
In-Reply-To: <20070728013950.GE15129@stusta.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Adrian Bunk <bunk@stusta.de>, tony.luck@intel.com
Cc: Sam Ravnborg <sam@ravnborg.org>, Jan Dittmer <jdi@l4x.org>, Len Brown <lenb@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Sat, 2007-07-28 at 03:39 +0200, Adrian Bunk wrote:
> On Fri, Jul 27, 2007 at 04:21:47PM -0700, Luck, Tony wrote:
> > > So it seems on ia64 with gcc 3.3.6 there's some 8 byte alignment of the 
> > > array members?
> > >
> > > Sam and the ia64 maintainers Cc'ed - they might know better what's going 
> > > on here.
> > 
> > This ia64 maintainer is baffled ... but I don't see the problem here (perhaps
> > because my build machine has gcc 3.4.6).
> 
> 
> I found what causes this problem, and it only occurs during cross 
> compilation.
> 
> 
> The struct is:
> 
> #define ACPI_ID_LEN     9
> 
> struct acpi_device_id {
> 	 __u8 id[ACPI_ID_LEN];
> 	kernel_ulong_t driver_data;
> };
> 
> 
> When compiling for ia64, this results in:
> 
> struct acpi_device_id {
> 	__u8 id[9];
> 	uint64_t driver_data;
> };
> 
> 
> sizeof(struct acpi_device_id) for ia64 is due to different padding
> after id[] 20 bytes on i386 but 24 bytes on ia64.
> 
> scripts/mod/file2alias.c is compiled with HOSTCC and ensures that 
> kernel_ulong_t is correct (in this case uint64_t for ia64), but it can't 
> cope with different padding on different architectures.

This one should workaround it. Is this acceptable for now?
Don't know how to fix this in a cleaner way (but I am sure it's
possible... ). Maybe an IA64 guy who is more used to such things has a
better idea and could have a look at this if there is time...

   Thomas

-------------

Cross-compilation between e.g. i386 -> 64bit could break -> work around it

Adrian Bunk: scripts/mod/file2alias.c is compiled with HOSTCC and ensures that
kernel_ulong_t is correct, but it can't cope with different padding on
different architectures.

---
 include/linux/mod_devicetable.h |    2 ++
 1 file changed, 2 insertions(+)

Index: torvalds/include/linux/mod_devicetable.h
=================================--- torvalds.orig/include/linux/mod_devicetable.h
+++ torvalds/include/linux/mod_devicetable.h
@@ -160,9 +160,11 @@ struct ap_device_id {
 #define AP_DEVICE_ID_MATCH_DEVICE_TYPE		0x01
 
 #define ACPI_ID_LEN	9
+#define FILLUP_LEN	7 /* dirty fix for i386 -> 64bit cross-compilation */
 
 struct acpi_device_id {
 	__u8 id[ACPI_ID_LEN];
+	__u8 dummy[FILLUP_LEN];
 	kernel_ulong_t driver_data;
 };
 


