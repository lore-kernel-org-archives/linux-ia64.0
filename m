From: "Yu, Luming" <luming.yu@intel.com>
Date: Wed, 17 Dec 2003 03:07:22 +0000
Subject: RE: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107163050729367@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Did you look at /proc/iomem with and without your patch?  The
>value of keeping the request_resource() (or insert_resource())
>should be obvious.

My patch just eliminate resources provider from resource tree.
Maybe it's not good, but it will not confuse device driver.

