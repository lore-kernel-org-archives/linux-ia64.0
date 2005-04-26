From: Andrew Morton <akpm@osdl.org>
Date: Tue, 26 Apr 2005 09:57:16 +0000
Subject: Re: [RFC/PATCH 0/3] ACPI based I/O APIC hot-plug
Message-Id: <20050426025716.142c5726.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <4267AD0E.3080006@jp.fujitsu.com>
In-Reply-To: <4267AD0E.3080006@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Cc: len.brown@intel.com, tony.luck@intel.com, greg@kroah.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

"Kenji Kaneshige" <kaneshige.kenji@jp.fujitsu.com> wrote:
>
> Here is a set of patches to support ACPI based I/O APIC hotplug.

OK, with the help of Tony's git tree I managed to get those merged up.

In future, please avoid sending multiple patches with the same Subject:? 
Because when you do that I have to invent unique names for the patches and
you don't know what those names were, so things get confusing.  See
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt for more, thanks.


