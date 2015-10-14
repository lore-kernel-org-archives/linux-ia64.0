From: Al Stone <ahs3@redhat.com>
Date: Wed, 14 Oct 2015 20:20:51 +0000
Subject: Re: [Linaro-acpi] [PATCH v5 0/5] Provide better MADT subtable sanity checks
Message-Id: <561EB923.6010109@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020400080004050109020606"
List-Id: <linux-ia64.vger.kernel.org>
References: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
 <560BA4C9.7090607@huawei.com> <560C0968.6020904@redhat.com>
 <2808057.teMg2oCLf6@vostro.rjw.lan> <5612AF64.4060900@redhat.com>
 <561B2442.9050600@erley.org> <561B2DAD.5070601@linaro.org>
 <561B2FCA.1010504@erley.org> <561C1D87.8010106@linaro.org>
 <561C8351.3030304@erley.org>
In-Reply-To: <561C8351.3030304@erley.org>
To: Pat Erley <pat-lkml@erley.org>, Al Stone <al.stone@linaro.org>, Hanjun Guo <hanjun.guo@linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, linaro-acpi@lists.linaro.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, patches@linaro.org, Hanjun Guo <guohanjun@huawei.com>, linux-arm-kernel@lists.infradead.org

This is a multi-part message in MIME format.
--------------020400080004050109020606
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 10/12/2015 10:06 PM, Pat Erley wrote:
> On 10/12/2015 01:52 PM, Al Stone wrote:
>> On 10/11/2015 09:58 PM, Pat Erley wrote:
>>> On 10/11/2015 08:49 PM, Hanjun Guo wrote:
>>>> On 10/12/2015 11:08 AM, Pat Erley wrote:
>>>>> On 10/05/2015 10:12 AM, Al Stone wrote:
>>>>>> On 10/05/2015 07:39 AM, Rafael J. Wysocki wrote:
>>>>>>> On Wednesday, September 30, 2015 10:10:16 AM Al Stone wrote:
>>>>>>>> On 09/30/2015 03:00 AM, Hanjun Guo wrote:
>>>>>>>>> On 2015/9/30 7:45, Al Stone wrote:
>>>>>>>>>> NB: this patch set is for use against the linux-pm bleeding edge
>>>>>>>>>> branch.
>>>>>>>>>>
>>>>>>>>
>>>>>>>> [snip...]
>>>>>>>>
>>>>>>>>>
>>>>>>>>> For this patch set,
>>>>>>>>>
>>>>>>>>> Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>
>>>>>>>>>
>>>>>>>>> Thanks
>>>>>>>>> Hanjun
>>>>>>>>
>>>>>>>> Thanks, Hanjun!
>>>>>>>
>>>>>>> Series applied, thanks!
>>>>>>>
>>>>>>> Rafael
>>>>>>>
>>>>>>
>>>>>> Thanks, Rafael!
>>>>>>
>>>>>
>>>>> Just decided to test out linux-next (to see the new nouveau cleanups).
>>>>> This change set prevents my Lenovo W510 from booting properly.
>>>>>
>>>>> Reverting: 7494b0 "ACPI: add in a bad_madt_entry() function to
>>>>> eventually replace the macro"
>>>>>
>>>>> Gets the system booting again.  I'm attaching my dmesg from the failed
>>>>> boot, who wants the acpidump?
>>>>
>>>> [    0.000000] ACPI: undefined version for either FADT 4.0 or MADT 1
>>>> [    0.000000] ACPI: Error parsing LAPIC address override entry
>>>> [    0.000000] ACPI: Invalid BIOS MADT, disabling ACPI
>>>>
>>>> Seems the MADT revision is not right, could you dump the ACPI MADT
>>>> (APIC) table and send it out? I will take a look :)
>>>>
>>>> Thanks
>>>> Hanjun
>>>
>>> Here ya go, enjoy.  Feel free to CC me on any patches that might fix it.
>>
>> Pat,
>>
>> Would you mind sending a copy of the FADT, also, please?  The first of the
>> ACPI messages is a check of version correspondence between the FADT and MADT,
>> while the second message is from looking at just an MADT subtable.  Thanks
>> for sending the MADT out -- that helps me quite a lot in thinking this through.
>>
>> BTW, whoever is providing the BIOS (Lenovo, I assume) may want to have a look
>> at these, also:
>>
>> [    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in
>> FADT/Pm1aControlBlock: 16/32 (20150818/tbfadt-623)
>> [    0.000000] ACPI BIOS Warning (bug): Invalid length for
>> FADT/Pm1aControlBlock: 32, using default 16 (20150818/tbfadt-704)
>>
>> Not inherently dangerous, but definitely sloppy and mind-numbingly easy to
>> avoid, IIRC.
>>
> 
> Here ya go.

Okay.  There's just a lot of weird stuff out there in ACPI-land.  I've
attached four minor fixes for the special cases that have been reported
(well, the last one is actually a fix for a typo in the spec, but just
the same...).

These should apply on top of linux-next; would you mind trying them out
to make sure I didn't break anything else on your laptop?  If they behave
as I hope they will, I think I'll have covered all the places where the
checking of MADT subtables needs to be be relaxed a bit.  These work for
me on arm64, but if they work for you and a couple of other testers, then
I'll send them to Rafael properly.

Many thanks!

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Red Hat, Inc.
ahs3@redhat.com
-----------------------------------

--------------020400080004050109020606
Content-Type: text/x-patch;
 name="0001-ACPI-workaround-x86-firmware-using-reserved-MADT-sub.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ACPI-workaround-x86-firmware-using-reserved-MADT-sub.pa";
 filename*1="tch"

From 52a2011c4998674d80c4456e6fd8ba11beaee65c Mon Sep 17 00:00:00 2001
From: Al Stone <ahs3@redhat.com>
Date: Tue, 13 Oct 2015 15:29:15 -0600
Subject: [PATCH 1/4] ACPI: workaround x86 firmware using reserved MADT
 subtable IDs

According to the ACPI specification, version 6.0, table 5-46,  MADT
subtable IDs in the range of 0x10-0x7f are reserved for possible
future use by the specification.  The function bad_madt_entry() tries
to enforce the spec, but it turns out there are x86 machines that use
0x7f even though they should not.

So, continue to enforce this rule for arm64, since we're starting out
fresh, but relax it for systems already out there so we don't keep them
from booting.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/tables.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index a2ed38a..e5cfd72 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -413,9 +413,17 @@ static int __init bad_madt_entry(struct acpi_table_header *table,
 	}
 
 	if (entry->type >= ms->num_types) {
-		pr_err("undefined MADT subtable type for FADT %d.%d: %d (length %d)\n",
-		       major, minor, entry->type, entry->length);
-		return 1;
+		if (IS_ENABLED(CONFIG_ARM64)) {
+			/* Enforce this stricture on arm64... */
+			pr_err("undefined MADT subtable type for FADT %d.%d: %d (length %d)\n",
+			       major, minor, entry->type, entry->length);
+			return 1;
+		} else {
+			/* ... but relax it on legacy systems so they boot */
+			pr_warn("undefined MADT subtable type for FADT %d.%d: %d (length %d)\n",
+			         major, minor, entry->type, entry->length);
+			return 0;
+		}
 	}
 
 	/* verify that the table is allowed for this version of the spec */
-- 
2.4.3


--------------020400080004050109020606
Content-Type: text/x-patch;
 name="0002-ACPI-workaround-x86-firmware-with-mis-matched-FADT-M.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0002-ACPI-workaround-x86-firmware-with-mis-matched-FADT-M.pa";
 filename*1="tch"

From 8b7e93421a1bd3a35ed6200fb778b87e9bff34c5 Mon Sep 17 00:00:00 2001
From: Al Stone <ahs3@redhat.com>
Date: Tue, 13 Oct 2015 15:51:13 -0600
Subject: [PATCH 2/4] ACPI: workaround x86 firmware with mis-matched FADT/MADT
 revisions

Looking across multiple versions of the ACPI specification, certain
versions introduce new revision numbers for the FADT and/or MADT
tables.  So, for example, an FADT indicating it is revision 4 should
not be paired with an MADT revision of anything less than 2.

However, there are systems out there that do not update the revision
fields in the FADT and MADT tables as they should.  So, for arm64, we
can be stricter in complying with the specification, but we need to
relax the checking for legacy systems.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/tables.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index e5cfd72..3b5ddfb 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -407,9 +407,17 @@ static int __init bad_madt_entry(struct acpi_table_header *table,
 		ms++;
 	}
 	if (!ms->num_types) {
-		pr_err("undefined version for either FADT %d.%d or MADT %d\n",
-		       major, minor, madt->header.revision);
-		return 1;
+		if (IS_ENABLED(CONFIG_ARM64)) {
+			/* Enforce this stricture on arm64... */
+			pr_err("undefined version for either FADT %d.%d or MADT %d\n",
+			       major, minor, madt->header.revision);
+			return 1;
+		} else {
+			/* ... but relax it on legacy systems so they boot */
+			pr_warn("undefined version for either FADT %d.%d or MADT %d\n",
+			        major, minor, madt->header.revision);
+			return 0;
+		}
 	}
 
 	if (entry->type >= ms->num_types) {
-- 
2.4.3


--------------020400080004050109020606
Content-Type: text/x-patch;
 name="0003-ACPI-workaround-FADT-always-being-revision-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0003-ACPI-workaround-FADT-always-being-revision-2.patch"

From 773dd448360098b6faf6c171dd716371d603f3ef Mon Sep 17 00:00:00 2001
From: Al Stone <ahs3@redhat.com>
Date: Tue, 13 Oct 2015 16:23:21 -0600
Subject: [PATCH 3/4] ACPI: workaround FADT always being revision 2

In some environments, the FADT revision number is always 2, independent
of any other factors indicating that it may be a newer revision.  So,
we cannot rely on the FADT and MADT revisions being in proper step.  For
those environments, relax the checking so we only enforce the size check,
even if we do issue warnings on other problems.

If we do not relax the rules, these systems will not boot as they have in
the past.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/tables.c | 34 +++++++++++++++++++++++++++++-----
 1 file changed, 29 insertions(+), 5 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 3b5ddfb..790d4b0 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -416,7 +416,6 @@ static int __init bad_madt_entry(struct acpi_table_header *table,
 			/* ... but relax it on legacy systems so they boot */
 			pr_warn("undefined version for either FADT %d.%d or MADT %d\n",
 			        major, minor, madt->header.revision);
-			return 0;
 		}
 	}
 
@@ -430,16 +429,41 @@ static int __init bad_madt_entry(struct acpi_table_header *table,
 			/* ... but relax it on legacy systems so they boot */
 			pr_warn("undefined MADT subtable type for FADT %d.%d: %d (length %d)\n",
 			         major, minor, entry->type, entry->length);
-			return 0;
 		}
 	}
 
 	/* verify that the table is allowed for this version of the spec */
 	len = ms->lengths[entry->type];
 	if (!len) {
-		pr_err("MADT subtable %d not defined for FADT %d.%d\n",
-			 entry->type, major, minor);
-		return 1;
+		if (IS_ENABLED(CONFIG_ARM64)) {
+			pr_err("MADT subtable %d not defined for FADT %d.%d\n",
+			       entry->type, major, minor);
+			return 1;
+		} else {
+			pr_warn("MADT subtable %d not defined for FADT %d.%d\n",
+			        entry->type, major, minor);
+		}
+	}
+
+	/*
+	 * When we get this far, we may have issued warnings on either
+	 * a mismatch in FADT/MADT revisions, or have noted that the subtable
+	 * ID is not defined for the MADT revision we're using.  On some
+	 * architectures, this is an error, but for legacy systems, we need
+	 * to push on with other checks of the subtable.
+	 *
+	 * In fact, there are environments where the *only* value the FADT
+	 * revision will ever have is 2, regardless of anything else.  So,
+	 * for those systems to boot, we have to pretend the MADT is the
+	 * latest version to allow all known subtables since we have no way
+	 * to determine what revision it should be.
+	 */
+	if (!IS_ENABLED(CONFIG_ARM64) && major == 2) {
+		ms = spec_info;
+		while (ms->num_types != 0)
+			ms++;
+		ms--;
+		len = ms->lengths[entry->type];
 	}
 
 	/* verify that the length is what we expect */
-- 
2.4.3


--------------020400080004050109020606
Content-Type: text/x-patch;
 name="0004-ACPI-for-bad_madt_entry-the-GIC-ITS-table-is-20-byte.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0004-ACPI-for-bad_madt_entry-the-GIC-ITS-table-is-20-byte.pa";
 filename*1="tch"

From 6d3189ccfcbac9a61e6502df70499bd2ee808509 Mon Sep 17 00:00:00 2001
From: Al Stone <ahs3@redhat.com>
Date: Tue, 13 Oct 2015 16:31:50 -0600
Subject: [PATCH 4/4] ACPI: for bad_madt_entry(), the GIC ITS table is 20 bytes
 long, not 16

Correct a typo where bad_madt_entry() expected the MADT GIC ITS subtable
to be 16 bytes long, but it is actually 20 bytes.  This is a cut'n'paste
error picked up from the spec and inadvertently replicated in code.

Signed-off-by: Al Stone <al.stone@linaro.org>
---
 drivers/acpi/tables.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 790d4b0..1b7c13e 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -292,7 +292,7 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
  * GICD                  0xc                         24    24    24
  * GICv2m MSI            0xd                               24    24
  * GICR                  0xe                               16    16
- * GIC ITS               0xf                                     16
+ * GIC ITS               0xf                                     20
  *
  * In the table, each length entry is what should be in the length
  * field of the subtable, and -- in general -- it should match the
@@ -366,7 +366,7 @@ static struct acpi_madt_subtable_lengths spec_info[] = {
 		.madt_version = 3,
 		.num_types = 16,
 		.lengths = { 8, 12, 10, 8, 6, 12, 16, SUBTABLE_VARIABLE,
-			     16, 16, 12, 80, 24, 24, 16, 16 }
+			     16, 16, 12, 80, 24, 24, 16, 20 }
 	},
 	{ /* terminator */
 		.major_version = 0,
-- 
2.4.3


--------------020400080004050109020606--
