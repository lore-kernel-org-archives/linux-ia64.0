From: Christoph Hellwig <hch@caldera.de>
Date: Fri, 18 May 2001 16:59:32 +0000
Subject: Re: [Linux-ia64] GUID filesystem+device identification ?
Message-Id: <marc-linux-ia64-105590693005621@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005620@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005620@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, May 18, 2001 at 06:50:44PM +0200, Martin Wilck wrote:
> 
> Hi all,
> 
> Has anybody yet thought about the possibility to use
> a mechanism like devfs for identifying devices and file systems
> by their GUID? This would be a major improvement over Linux's current
> approach of identifying devices, particularly disk drives.
> 
> In principle, it would be possible to change controllers and
> disks arbitrarily and still maintain a valid file system in which
> all devices and sub-file systems would be identified by ther GUIDs
> (think of the device in fstab specified by GUID instead of /dev/sda3
> or whatever).

I think support for GUID=foo in /etc/fstab for mount would be pretty easy.
Having it in ther kernel would be nicer and shouldn't be that difficult,
on the other hand it'll need a consensus on wether the kernel should look
at every partition on startup - IIRC some people where opposed to such
soloutions in the past.

	Christoph
-- 
Of course it doesn't work. We've performed a software upgrade.

