From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 27 Jun 2006 21:00:59 +0000
Subject: RE: [PATCH] fix prom revision checks in SN kernel
Message-Id: <617E1C2C70743745A92448908E030B2A27F7A8@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200606271946.MAA19328@google.engr.sgi.com>
In-Reply-To: <200606271946.MAA19328@google.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

+	if (is_shub1() && version <= 0x0209 && acpi_kbd_controller_present) {
 ...
+	if (is_shub1() && sn_sal_rev() < 0x0406) {
 ...
+	if (is_shub1() && sn_sal_rev() < SGI_HOTPLUG_PROM_REV) {


Is it time to come up with a more elegant way of doing this?  One
place you have a define for the special revision, others you hard-wire
the hex numbers.  Possibly at some point in the future you might
have some dividing line in prom revisions for shub2 systems, so
if you continue in this path the tests will just get uglier.

Maybe some inline functions that hide things:

    if (sn_sal_supports_fadt() && acpi_kbd_controller_present) {

    if (sn_sal_supports_tioca()) {

    if (sn_sal_support_hotplug()) {

-Tony
