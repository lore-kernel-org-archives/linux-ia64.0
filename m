From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 05 Aug 2004 16:45:48 +0000
Subject: RE: [BROKEN PATCH] kexec for ia64
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F01CB2705@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>, "Eric W. Biederman" <ebiederm@xmission.com>, khalid.aziz@hp.com
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, linux-ia64@vger.kernel.org, fastboot@osdl.org, linux-kernel@vger.kernel.org

Jesse Barnes wrote:
>With the addition of some ACPI tables and such.  I don't think 
>those are freed by the kernel right now though, so it should
>be pretty easy to point at the originals from the newly kexec'd
>kernel, or make copies.

The "trim_bottom" and "trim_top" functions currently modify
the memory map in place.  But this would only make a difference
if you tried to kexec a kernel with a smaller granule size than
the originally running kernel, and even then would only
result in missing seeing some memory that you might have been
able to use.

-Tony
