From: Grant Grundler <iod00d@hp.com>
Date: Sun, 18 Jul 2004 02:37:23 +0000
Subject: Re: can't install redhat linux upgrade v3 on rx5670
Message-Id: <20040718023723.GA29764@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <071620042133.15591.40F849C10008D72500003CE72200750330040104040E05@comcast.net>
In-Reply-To: <071620042133.15591.40F849C10008D72500003CE72200750330040104040E05@comcast.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, Jul 17, 2004 at 01:14:21AM +0000, kallol@comcast.net wrote:
> Hello Grant,
>                       I could install debian linux from the hp enablement
> kit cd,

So what's the problem? :^)

> but RedHat Itanium cd V3.1 panics as it does not find the root filesystem.

Can you tell me *exactly* what the CD has printed on it?
I'm not familiar with any "V3.1" release for itanium.
I know about a RHAS 2.1 and RHEL 3.0 and there are a few more variants
that I don't recall.

> I guess the scsi driver is not present in the cd set. There should be
> a way to specify  the location of the scsi drivers.
> 
> The rx5670 system has symbios cards (lsi's script based cards).

Yes. the initrd has to contain the drivers and I expect the install
CD to have those. If the initrd does NOT, this can be fixed up
by hand by regenerating the initrd. Boot the install CD and
specific "root=/dev/sdXX" where "XX" is the right disk name.
I personally don't use either RH or initrd's so I'm not the
right person to help you with that.

> The dmesg is attached with the mail

I'll look at it and yell if anything is obvious.

grant
