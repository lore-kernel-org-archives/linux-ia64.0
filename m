From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 20 Feb 2003 19:18:28 +0000
Subject: [Linux-ia64] Re: GPT_HEADER_REVISION_V1_02
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------030305030108020406050403"
Message-Id: <marc-linux-ia64-105590709805892@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805884@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805884@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------030305030108020406050403
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Matt Domsch wrote:

> > We'll issue a clarification on this topic. For now, can we have parted
> > revert to GPT_HEADER_REVISION_V1_00 ?
>
> No objections.  Will you be submitting a patch, or should I?
>

The attached patch worked fine for me. When looking at a GPT with 
revision number 1.02, parted complains about a newer version number it 
doesn't know about, but if the user ignores it and flips a flag on one 
of the GPT partitions twice (essentially a nop), the GPT revision number 
gets downgraded to 1.0.

    -Arun



--------------030305030108020406050403
Content-Type: text/plain;
 name="gpt_ver.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gpt_ver.patch"

--- parted-1.6.3/libparted/disk_gpt.c-	2003-02-20 11:04:41.000000000 -0800
+++ parted-1.6.3/libparted/disk_gpt.c	2003-02-20 11:06:35.000000000 -0800
@@ -52,7 +52,6 @@
 #define MSDOS_MBR_SIGNATURE 0xaa55
 
 #define GPT_HEADER_SIGNATURE 0x5452415020494645
-#define GPT_HEADER_REVISION_V1_02 0x00010200
 #define GPT_HEADER_REVISION_V1_00 0x00010000
 #define GPT_HEADER_REVISION_V0_99 0x00009900
 
@@ -458,7 +457,7 @@
 	PED_ASSERT (_header_is_valid (gpt), return 0);
 
 #ifndef DISCOVER_ONLY
-	if (PED_CPU_TO_LE32 (gpt->Revision) > GPT_HEADER_REVISION_V1_02
+	if (PED_CPU_TO_LE32 (gpt->Revision) > GPT_HEADER_REVISION_V1_00
 	    || PED_CPU_TO_LE32 (gpt->HeaderSize) != 92) {
 		if (ped_exception_throw (
 			PED_EXCEPTION_WARNING,
@@ -702,7 +701,7 @@
 	memset (gpt, 0, sizeof (GuidPartitionTableHeader_t));
 
 	gpt->Signature = PED_CPU_TO_LE64 (GPT_HEADER_SIGNATURE);
-	gpt->Revision = PED_CPU_TO_LE32 (GPT_HEADER_REVISION_V1_02);
+	gpt->Revision = PED_CPU_TO_LE32 (GPT_HEADER_REVISION_V1_00);
 	gpt->HeaderSize = PED_CPU_TO_LE32 (92); /* per 1.02 spec */
 	gpt->HeaderCRC32 = 0;
 	gpt->Reserved1 = 0;

--------------030305030108020406050403--


