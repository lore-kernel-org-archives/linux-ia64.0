From: "Moore, Robert" <robert.moore@intel.com>
Date: Wed, 31 Aug 2005 22:04:24 +0000
Subject: RE: [ACPI] RE: One-line patch for systems with ACPI enabled but incomplete tree
Message-Id: <971FCB6690CD0E4898387DBF7552B90E029620CC@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E02961E28@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E02961E28@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Magenheimer, Dan (HP Labs Fort Collins)" <dan.magenheimer@hp.com>, "Brown, Len" <len.brown@intel.com>
Cc: acpi-devel@lists.sourceforge.net, hch@infradead.org, linux-ia64@vger.kernel.org

> there is no check in the kernel code.  However, it still seems
> like a bug to me as everything else works if the FADT pointer
> is zero (with the above one line patch).
[Moore, Robert] 

This is some legacy overkill in the code that we should remove or
change.  Once the ACPI tables are loaded, the FADT pointer should be
always valid.  There are some inconsistencies in detecting and handling
the error case where external ACPI CA interfaces are called before the
tables are loaded -- I believe that is the real purpose of the checks
for NULL table pointers scattered throughout.

Bob

