From: Frederic Weisbecker <fweisbec@gmail.com>
Date: Wed, 21 Jul 2010 23:16:42 +0000
Subject: Re: [PATCH 1/6] ia64/perfmon: convert to unlocked_ioctl
Message-Id: <20100721231640.GA5801@nowhere>
List-Id: <linux-ia64.vger.kernel.org>
References: <1278195310-25590-1-git-send-email-arnd@arndb.de> <1278195310-25590-2-git-send-email-arnd@arndb.de>
In-Reply-To: <1278195310-25590-2-git-send-email-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, John Kacur <jkacur@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

On Sun, Jul 04, 2010 at 12:15:05AM +0200, Arnd Bergmann wrote:
> The ioctl function in this driver does not
> do anything that requires the BKL, so make
> it use unlocked_ioctl.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: linux-ia64@vger.kernel.org
> ---


Applied, thanks!

