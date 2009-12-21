From: Dominik Brodowski <linux@dominikbrodowski.net>
Date: Mon, 21 Dec 2009 08:15:50 +0000
Subject: Re: [PATCH 00/11] ACPI: early _PDC eval and unify x86/ia64
Message-Id: <20091221081550.GA1648@isilmar.linta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220190434.4274.67855.stgit@bob.kio>
In-Reply-To: <20091220190434.4274.67855.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: venkatesh.pallipadi@intel.com, lenb@kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Hey,

On Sun, Dec 20, 2009 at 12:19:04PM -0700, Alex Chiang wrote:
> This does introduce a boot time namespace walk for all the CPUs
> in the system, looking for and evaluating _PDC. Hopefully that
> will not make life miserable for the giant SGI clusters. If worse
> comes to worse, maybe we can quirk them and avoid the namespace
> walk.

Could this be done async, with completion before EC initialization?

Best,
	Dominik
