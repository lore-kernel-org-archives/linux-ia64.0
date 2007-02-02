From: Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com>
Date: Fri, 02 Feb 2007 14:20:35 +0000
Subject: Re: 2.6.20-rc6-mm[2-3] ACPI issues
Message-Id: <45C348B3.8000805@linux.intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050505040604030701050101"
List-Id: <linux-ia64.vger.kernel.org>
References: <20070131202532.GS30233@localhost> <200702010155.02119.lenb@kernel.org> <20070201164709.GA17678@localhost>
In-Reply-To: <20070201164709.GA17678@localhost>
To: Bob Picco <bob.picco@hp.com>
Cc: Len Brown <lenb@kernel.org>, akpm@osdl.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------050505040604030701050101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Bob Picco wrote:
> BTW, this isn't specific to rx2600. Lee Schermerhorn reported same -mm3 problem 
> on rx8620. Stephane Eranian reported the -mm2 problem mentioned above on rx2620.
>
> The debug information you requested is below. 
>
> thanks,
>
> bob
Bob, thanks for debug information.
Could you please try following patch?

Thanks,
    Alex.

--------------050505040604030701050101
Content-Type: text/plain;
 name="fix-tbfadt.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix-tbfadt.c"

Copy space_id of GAS structure to newly created GAS.

From: Alexey Starikovskiy <alexey.y.starikovskiy@linux.intel.com>


---

 drivers/acpi/tables/tbfadt.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/acpi/tables/tbfadt.c b/drivers/acpi/tables/tbfadt.c
index 30350dd..807c711 100644
--- a/drivers/acpi/tables/tbfadt.c
+++ b/drivers/acpi/tables/tbfadt.c
@@ -333,6 +333,8 @@ static void acpi_tb_convert_fadt(void)
 				     pm1_register_length,
 				     (acpi_gbl_FADT.xpm1a_event_block.address +
 				      pm1_register_length));
+	/* Don't forget to copy space_id of the GAS */
+	acpi_gbl_xpm1a_enable.space_id = acpi_gbl_FADT.xpm1a_event_block.space_id;
 
 	/* The PM1B register block is optional, ignore if not present */
 
@@ -341,6 +343,9 @@ static void acpi_tb_convert_fadt(void)
 					     pm1_register_length,
 					     (acpi_gbl_FADT.xpm1b_event_block.
 					      address + pm1_register_length));
+		/* Don't forget to copy space_id of the GAS */
+		acpi_gbl_xpm1b_enable.space_id = acpi_gbl_FADT.xpm1a_event_block.space_id;
+
 	}
 }
 

--------------050505040604030701050101--
