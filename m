From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 23 Jul 2018 21:00:15 +0000
Subject: Re: [PATCH 0/4] ia64: switch to NO_BOOTMEM
Message-Id: <20180723210015.GA7058@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
References: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 23, 2018 at 08:56:54AM +0300, Mike Rapoport wrote:
> Hi,
> 
> These patches convert ia64 to use NO_BOOTMEM.
> 
> The first two patches are cleanups, the third patches reduces usage of
> 'struct bootmem_data' for easier transition and the forth patch actually
> replaces bootmem with memblock + nobootmem.
> 
> I've tested the sim_defconfig with the ski simulator and build tested other
> defconfigs.

Boots OK on my real ia64 system.

Unless somebody else sees an issue I'll push to Linus nest merge window.

-Tony
