From: "Luis R. Rodriguez" <mcgrof@suse.com>
Date: Fri, 12 Jun 2015 00:58:50 +0000
Subject: Re: [PATCH] ia64: export flush_icache_range for module use
Message-Id: <CAB=NE6WrKaWaPdk_fe_s2KnASjKj10gsMK2Kv0=k3eW+oWxu7g@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433270039-1527-1-git-send-email-mcgrof@do-not-panic.com>
In-Reply-To: <1433270039-1527-1-git-send-email-mcgrof@do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, pbonzini@redhat.com, Boris Ostrovsky <boris.ostrovsky@oracle.com>, "Luis R. Rodriguez" <mcgrof@suse.com>

On Tue, Jun 2, 2015 at 11:33 AM, Luis R. Rodriguez
<mcgrof@do-not-panic.com> wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
>
> This is needed the following modules:
>
> "Linux Kernel Dump Test Tool Module"
> CONFIG_LKDTM            drivers/misc/lkdtm.c
>
> Since:
> mcgrof@ergon ~/linux-next (git::master)$ git describe --contains aac416fc38cdf
> v3.15-rc1~141^2~84
>
> CONFIG_STI_CONSOLE      drivers/video/console/sticore.c
> Since: beginning of new git time on Linux
>
> Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>

Just a friendly reminder. Let me know if there are any issues.

 Luis
