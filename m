From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Mon, 24 Jan 2005 16:53:36 +0000
Subject: Re: bk pull on ia64 linux tree
Message-Id: <200501240853.36945.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday, January 22, 2005 7:05 pm, Luck, Tony wrote:
> <tony.luck@intel.com> (05/01/22 1.2017)
>    [IA64] clean up loose ends from addition of efi_range_is_wc()
>
>    Signed-off-by: Tony Luck <tony.luck@intel.com>

Thanks for adding the export, I don't do modules very often.  But does drm 
really need the #ifdef __ia64__ around the include of efi.h?  Isn't that file 
safe to include unconditionally?

Thanks,
Jesse
