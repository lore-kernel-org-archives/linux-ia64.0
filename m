From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 12 Nov 2003 06:33:54 +0000
Subject: Re: Building 2.6.0-test9 without ACPI
MIME-Version: 1
Content-Type: multipart/mixed; boundary="IS0zKkzwUGydFO0o"
Message-Id: <marc-linux-ia64-106861885901226@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106861699532525@msgid-missing>
In-Reply-To: <marc-linux-ia64-106861699532525@msgid-missing>
To: linux-ia64@vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 11, 2003 at 10:06:38PM -0800, Grant Grundler wrote:
> ACPI is required. It's how ia64 platform resources are discovered.
> The fix would be to force ACPI on if any ia64 target is selected.

Doh! I did know that but got all excited when I saw you could turn it
off.  My fault as usual.  Maybe the attached could be slipped in
whenever it is appropriate.

-i

--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="Kconfig-acpi.patch"

===== arch/ia64/Kconfig 1.48 vs edited =====
--- 1.48/arch/ia64/Kconfig	Wed Oct 15 18:35:33 2003
+++ edited/arch/ia64/Kconfig	Wed Nov 12 17:24:47 2003
@@ -10,6 +10,7 @@
 menu "Processor type and features"
 
 config IA64
+	select ACPI
 	bool
 	default y
 	help

--IS0zKkzwUGydFO0o--
