From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 20 Feb 2003 02:36:38 +0000
Subject: [Linux-ia64] GPT_HEADER_REVISION_V1_02
Message-Id: <marc-linux-ia64-105590709805883@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We noticed that parted-1.6.3 is using GPT_HEADER_REVISION_V1_02 in the
GPT header. This is probably due to the ambiguity in the EFI spec about
what the revision number in the GPT means. The intention was that this
revision number is not necessarily the same as the EFI spec number.

We'll issue a clarification on this topic. For now, can we have parted
revert to GPT_HEADER_REVISION_V1_00 ?

Not fixing this may result in incompatibility with other disk
partitioning tools.

	-Arun



