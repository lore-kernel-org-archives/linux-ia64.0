From: Grant Grundler <iod00d@hp.com>
Date: Wed, 12 Nov 2003 06:06:38 +0000
Subject: Re: Building 2.6.0-test9 without ACPI
Message-Id: <marc-linux-ia64-106861720732740@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106861699532525@msgid-missing>
In-Reply-To: <marc-linux-ia64-106861699532525@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Nov 12, 2003 at 05:02:47PM +1100, Ian Wienand wrote:
> To try and debug I went to turn ACPI off in menuconfig, but it doesn't
> seem to actually turn ACPI off properly.

ACPI is required. It's how ia64 platform resources are discovered.
The fix would be to force ACPI on if any ia64 target is selected.

grant
