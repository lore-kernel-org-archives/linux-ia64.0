From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 26 Sep 2003 01:54:24 +0000
Subject: Re: [PATCH] discontig patch (work in progress)
Message-Id: <marc-linux-ia64-106454127620574@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106436165231302@msgid-missing>
In-Reply-To: <marc-linux-ia64-106436165231302@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Sep 25, 2003 at 06:45:57PM -0700, Jesse Barnes wrote:
> This patch fixes the last one by not changing around the callback args.
> All are physical addr, length pairs now.

Oh, and it doesn't break zx1 either.  Boot tested zx1 and sn2 configs.

Jesse
