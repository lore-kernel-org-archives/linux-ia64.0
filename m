From: Al Stone <al.stone@linaro.org>
Date: Wed, 16 Sep 2015 23:26:41 +0000
Subject: [PATCH v4 1/5] ACPI: add in a bad_madt_entry() function to eventually replace the macro
Message-Id: <1442446005-19799-2-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1442446005-19799-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1442446005-19799-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, Al Stone <al.stone@linaro.org>, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Len Brown <lenb@kernel.org>

The existing BAD_MADT_ENTRY macro only checks that the size of the data
structure for an MADT subtable matches the length entry in the subtable.
This is, unfortunately, not reliable.  Nor, as it turns out, does it have
anything to do with what the length should be in any particular table.

We introduce the bad_madt_entry() function that uses a data set to
do some basic sanity checks on any given MADT subtable.  Over time, as
the spec changes, we should just be able to add entries to the data set
to reflect the changes.

What the data set captures is the allowed MADT subtable length for each
type of subtable, for each revision of the specification.  While there
is a revision number in the MADT that we should be able to use to figure
out the proper subtable length, it was not changed when subtables did.
And, while there is a major and minor revision in the FADT that could
also help, it was not always changed as the subtables changed either.
So, the data set captures for each published version of the ACPI spec
what the FADT revisions numbers should be, the corresponding MADT
revision number, and the subtable types and lengths that were defined
at that time.

The sanity checks done are:
	-- is the length non-zero?
	-- is the subtable type defined/allowed for the revision of
	   the FADT we're using?
	-- is the subtable type defined/allowed for the revision of
	   the MADT we're using?
	-- is the length entry what it should be for this revision
	   of the MADT and FADT?

These checks are more thorough than the previous macro provided, and
are now insulated from data structure size changes by ACPICA, which
have been the source of other patches in the past.

Now that the bad_madt_entry() function is available, we add code to
also invoke it before any subtable handlers are called to use the
info in the subtable.  Subsequent patches will remove the use of the
BAD_MADT_ENTRY macro which is now redundant as a result.  Any ACPI
functions that use acpi_parse_madt_entries() will always have all of
the MADT subtables checked from now on.

Signed-off-by: Al Stone <al.stone@linaro.org>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
---
 drivers/acpi/tables.c | 244 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 244 insertions(+)

diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
index 17a6fa0..79d73e5 100644
--- a/drivers/acpi/tables.c
+++ b/drivers/acpi/tables.c
@@ -210,6 +210,247 @@ void acpi_table_print_madt_entry(struct acpi_subtable_header *header)
 	}
 }
 
+/*
+ * The Long, Sad, True Story of the MADT
+ *    or
+ * What does bad_madt_entry() actually do?
+ *
+ * Once upon a time in ACPI 1.0, there was the MADT.  It was a nice table,
+ * and it had two subtables all of its own.  But, it was also a pretty
+ * busy table, too, so over time the MADT gathered up other nice little
+ * subtables.  By the time ACPI 6.0 came around, the MADT had 16 of the
+ * little guys.
+ *
+ * Now, the MADT kept a little counter around for the subtables.  In fact,
+ * it kept two counters: one was the revision level, which was supposed to
+ * change when new subtables came to be, or as the ones already around grew
+ * up. The second counter was a type number, because the MADT needed a unique
+ * type for each subtable so he could tell them apart.  But, sometimes the
+ * MADT got so busy, he forgot to increment the revision level when he needed
+ * to.  Fortunately, the type counter kept increasing since that's the only
+ * way the MADT could find each little subtable.  It just wouldn't do to have
+ * every subtable called Number 6.
+ *
+ * In the next valley over, a castle full of wizards was watching the MADT
+ * and made a pact to keep their own counter.  Every time the MADT found a
+ * new subtable, or a subtable grew up, the wizards promised they would
+ * increment their counter.  Well, wizards being the forgetful sort, they
+ * didn't alway do that.  And, since there quite a lot of them, they
+ * couldn't always remember who was supposed to keep track of the MADT,
+ * especially if dinner was coming up soon.  Their counter was called the
+ * spec version.
+ *
+ * Every now and then, the MADT would gather up all its little subtables
+ * and take them in to the cobbler to get new boots.  This was a very, very
+ * meticulous cobbler, so every time they came, he wrote down all the boot
+ * sizes for all of the little subtables.  The cobbler would ask each subtable
+ * for its length, check that against his careful notes, and then go get the
+ * right boots.  Sometimes, a little subtable would change a bit, and their
+ * length did not match what the cobbler had written down.  If the wizards
+ * or the MADT had incremented their counters, the cobbler would breath a
+ * sigh of relief and write down the new length as the right one.  But, if
+ * none of the counters had changed, this would make the cobbler very, very
+ * mad.  He couldn't tell if he had the right size boots or not for the
+ * little subtable.  He would have to *guess* and this really bugged him.
+ *
+ * Well, when the cobbler got mad like this, he would go into hiding.  He
+ * would not make or sell any boots.  He would not go out at all.  Pretty
+ * soon, the coffee shop would have to close because the cobbler wasn't
+ * coming by twice a day any more.  Then the grocery store would have to
+ * close because he wouldn't eat much.  After a while, everyone would panic
+ * and have to move from the village and go live with all their relatives
+ * (usually the ones they didn't like very much).
+ *
+ * Eventually, the cobbler would work his way out of his bad mood, and
+ * open up his boot business again.  Then, everyone else could move back
+ * to the village and restart their lives, too.
+ *
+ * Fortunately, we have been able to collect up all the cobbler's careful
+ * notes (and we wrote them down below).  We'll have to keep checking these
+ * notes over time, too, just as the cobbler does.  But, in the meantime,
+ * we can avoid the panic and the reboot since we can make sure that each
+ * subtable is doing okay.  And that's what bad_madt_entry() does.
+ *
+ *
+ * FADT Major Version ->       1    3    4     4     5     5     6
+ * FADT Minor Version ->       x    x    x     x     x     1     0
+ * MADT revision ->            1    1    2     3     3     3     3
+ * Spec Version ->            1.0  2.0  3.0b  4.0a  5.0b  5.1a  6.0
+ * Subtable Name	Type  Expected Length ->
+ * Processor Local APIC  0x0    8    8    8     8     8     8     8
+ * IO APIC               0x1   12   12   12    12    12    12    12
+ * Int Src Override      0x2        10   10    10    10    10    10
+ * NMI Src               0x3         8    8     8     8     8     8
+ * Local APIC NMI Struct 0x4         6    6     6     6     6     6
+ * Local APIC Addr Ovrrd 0x5        16   12    12    12    12    12
+ * IO SAPIC              0x6        20   16    16    16    16    16
+ * Local SAPIC           0x7         8  >16   >16   >16   >16   >16
+ * Platform Int Src      0x8        16   16    16    16    16    16
+ * Proc Local x2APIC     0x9                   16    16    16    16
+ * Local x2APIC NMI      0xa                   12    12    12    12
+ * GICC CPU I/F          0xb                         40    76    80
+ * GICD                  0xc                         24    24    24
+ * GICv2m MSI            0xd                               24    24
+ * GICR                  0xe                               16    16
+ * GIC ITS               0xf                                     16
+ *
+ * In the table, each length entry is what should be in the length
+ * field of the subtable, and -- in general -- it should match the
+ * size of the struct for the subtable.  Any value that is not set
+ * (i.e., is zero) indicates that the subtable is not defined for
+ * that version of the ACPI spec.
+ *
+ */
+#define SUBTABLE_UNDEFINED	0x00
+#define SUBTABLE_VARIABLE	0xff
+#define NUM_SUBTABLE_TYPES	16
+
+struct acpi_madt_subtable_lengths {
+	unsigned short major_version;	/* from revision in FADT header */
+	unsigned short minor_version;	/* FADT field starting with 5.1 */
+	unsigned short madt_version;	/* MADT revision */
+	unsigned short num_types;	/* types possible for this version */
+	unsigned short lengths[NUM_SUBTABLE_TYPES];
+					/* subtable lengths, indexed by type */
+};
+
+static struct acpi_madt_subtable_lengths spec_info[] = {
+	{ /* for ACPI 1.0 */
+		.major_version = 1,
+		.minor_version = 0,
+		.madt_version = 1,
+		.num_types = 2,
+		.lengths = { 8, 12 }
+	},
+	{ /* for ACPI 2.0 */
+		.major_version = 3,
+		.minor_version = 0,
+		.madt_version = 1,
+		.num_types = 9,
+		.lengths = { 8, 12, 10, 8, 6, 16, 20, 8, 16 }
+	},
+	{ /* for ACPI 3.0b */
+		.major_version = 4,
+		.minor_version = 0,
+		.madt_version = 2,
+		.num_types = 9,
+		.lengths = { 8, 12, 10, 8, 6, 12, 16, SUBTABLE_VARIABLE, 16 }
+	},
+	{ /* for ACPI 4.0a */
+		.major_version = 4,
+		.minor_version = 0,
+		.madt_version = 3,
+		.num_types = 11,
+		.lengths = { 8, 12, 10, 8, 6, 12, 16, SUBTABLE_VARIABLE,
+			     16, 16, 12 }
+	},
+	{ /* for ACPI 5.0b */
+		.major_version = 5,
+		.minor_version = 0,
+		.madt_version = 3,
+		.num_types = 13,
+		.lengths = { 8, 12, 10, 8, 6, 12, 16, SUBTABLE_VARIABLE,
+			     16, 16, 12, 40, 24 }
+	},
+	{ /* for ACPI 5.1a */
+		.major_version = 5,
+		.minor_version = 1,
+		.madt_version = 3,
+		.num_types = 15,
+		.lengths = { 8, 12, 10, 8, 6, 12, 16, SUBTABLE_VARIABLE,
+			     16, 16, 12, 76, 24, 24, 16 }
+	},
+	{ /* for ACPI 6.0 */
+		.major_version = 6,
+		.minor_version = 0,
+		.madt_version = 3,
+		.num_types = 16,
+		.lengths = { 8, 12, 10, 8, 6, 12, 16, SUBTABLE_VARIABLE,
+			     16, 16, 12, 80, 24, 24, 16, 16 }
+	},
+	{ /* terminator */
+		.major_version = 0,
+		.minor_version = 0,
+		.madt_version = 0,
+		.num_types = 0,
+		.lengths = { 0 }
+	}
+};
+
+static int __init bad_madt_entry(struct acpi_table_header *table,
+				 struct acpi_subtable_header *entry)
+{
+	struct acpi_madt_subtable_lengths *ms;
+	struct acpi_table_madt *madt;
+	unsigned short major;
+	unsigned short minor;
+	unsigned short len;
+
+	/* simple sanity checking on MADT subtable entries */
+	if (!entry || !table)
+		return 1;
+
+	/* FADT minor numbers were not introduced until ACPI 5.1 */
+	major = acpi_gbl_FADT.header.revision;
+	if (major >= 5 && acpi_gbl_FADT.header.length >= 268)
+		minor = acpi_gbl_FADT.minor_revision;
+	else
+		minor = 0;
+
+	madt = (struct acpi_table_madt *)table;
+	ms = spec_info;
+	while (ms->num_types != 0) {
+		if (ms->major_version = major &&
+		    ms->minor_version = minor &&
+		    ms->madt_version = madt->header.revision)
+			break;
+		ms++;
+	}
+	if (!ms->num_types) {
+		pr_err("undefined version for either FADT %d.%d or MADT %d\n",
+		       major, minor, madt->header.revision);
+		return 1;
+	}
+
+	if (entry->type >= ms->num_types) {
+		pr_err("undefined MADT subtable type for FADT %d.%d: %d (length %d)\n",
+		       major, minor, entry->type, entry->length);
+		return 1;
+	}
+
+	/* verify that the table is allowed for this version of the spec */
+	len = ms->lengths[entry->type];
+	if (!len) {
+		pr_err("MADT subtable %d not defined for FADT %d.%d\n",
+			 entry->type, major, minor);
+		return 1;
+	}
+
+	/* verify that the length is what we expect */
+	if (len = SUBTABLE_VARIABLE) {
+		if (entry->type = ACPI_MADT_TYPE_LOCAL_SAPIC) {
+			struct acpi_madt_local_sapic *lsapic +				(struct acpi_madt_local_sapic *)entry;
+			int proper_len = sizeof(struct acpi_madt_local_sapic) +
+					 strlen(lsapic->uid_string) + 1;
+
+			if (proper_len != entry->length) {
+				pr_err("Variable length MADT subtable %d is wrong length: %d, should be: %d\n",
+				       entry->type, entry->length, proper_len);
+				return 1;
+			}
+		}
+	} else {
+		if (entry->length != len) {
+			pr_err("MADT subtable %d is wrong length: %d, should be: %d\n",
+			       entry->type, entry->length, len);
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 int __init
 acpi_parse_entries(char *id, unsigned long table_size,
 		acpi_tbl_entry_handler handler,
@@ -245,6 +486,9 @@ acpi_parse_entries(char *id, unsigned long table_size,
 	       table_end) {
 		if (entry->type = entry_id
 		    && (!max_entries || count < max_entries)) {
+			if (!strncmp(id, ACPI_SIG_MADT, 4) &&
+			    bad_madt_entry(table_header, entry))
+				return -EINVAL;
 			if (handler(entry, table_end))
 				return -EINVAL;
 
-- 
2.4.3

