From: Matthew Wilcox <willy@debian.org>
Date: Fri, 23 Apr 2004 12:30:57 +0000
Subject: Re: [Pcihpd-discuss] [RFC] New sysfs tree for hotplug
Message-Id: <20040423123057.GE22558@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040415170939.0ff62618.tokunaga.keiich@jp.fujitsu.com> <20040416223436.GB21701@kroah.com> <20040423211816.152dc326.tokunaga.keiich@jp.fujitsu.com>
In-Reply-To: <20040423211816.152dc326.tokunaga.keiich@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Cc: Greg KH <greg@kroah.com>, lhcs-devel@lists.sourceforge.net, lhms-devel@lists.sourceforge.net, linux-hotplug-devel@lists.sourceforge.net, pcihpd-discuss@lists.sourceforge.net, lhns-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, acpi-largesys-devel@lists.sourceforge.net

On Fri, Apr 23, 2004 at 09:18:16PM +0900, Keiichiro Tokunaga wrote:
> That's right.  /sys/devices/hotplug/ACPI/ tree becomes hard-wired one.  I was
> thinking to define the board by using ACPI (as a "generic container device" in
> ACPI namespace).  Therefore, if there is the new tree I proposed in the kernel,
> it would be easy to represent the hierarchy, and a directory for the board
> appears in the new tree.  So I thought that we could put an control file to
> invoke the board hotplug and an information file under the directory.
> (Actually, I've made a rough patch for the new tree and it seems to work fine:)
> I also thought that interface for hotplug could be unified so that it would become
> easier for user to use.

Have you seen Alex Williamson's patch to fill out the /sys/firmware/acpi tree?
http://marc.theaimsgroup.com/?l=linux-kernel&m8239031314885&w=2

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
