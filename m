From: Alex Chiang <achiang@hp.com>
Date: Sun, 20 Dec 2009 19:23:21 +0000
Subject: [PATCH 3/3] ACPI: processor: remove _PDC object list from struct
Message-Id: <20091220192321.5438.45589.stgit@bob.kio>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: venkatesh.pallipadi@intel.com, lenb@kernel.org
Cc: linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

When we call _PDC, we get a handle to the processor, allocate the
object list buffer as needed, and free it immediately after calling
_PDC.

There's no need to drag around this object list with us everywhere
else, so let's just get rid of it.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

 include/acpi/processor.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/acpi/processor.h b/include/acpi/processor.h
index 7cc433d..0ea5ef4 100644
--- a/include/acpi/processor.h
+++ b/include/acpi/processor.h
@@ -224,8 +224,6 @@ struct acpi_processor {
 	struct acpi_processor_throttling throttling;
 	struct acpi_processor_limit limit;
 	struct thermal_cooling_device *cdev;
-	/* the _PDC objects for this processor, if any */
-	struct acpi_object_list *pdc;
 };
 
 struct acpi_processor_errata {

