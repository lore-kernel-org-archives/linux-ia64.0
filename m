From: Baoquan He <bhe@redhat.com>
Date: Mon, 18 Apr 2016 10:12:14 +0000
Subject: Re: [PATCH 1/3] kexec: don't invoke OOM-killer for control page allocation
Message-Id: <20160418101214.GA6694@x1.redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160414195938.GV19428@n2100.arm.linux.org.uk>
 <E1aqnQo-0001Tu-Ch@rmk-PC.arm.linux.org.uk>
 <20160418053253.GA3602@x1.redhat.com>
 <20160418083932.GA19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160418083932.GA19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, kexec@lists.infradead.org

On 04/18/16 at 09:39am, Russell King - ARM Linux wrote:
> On Mon, Apr 18, 2016 at 01:32:53PM +0800, Baoquan He wrote:
> > On 04/14/16 at 09:00pm, Russell King wrote:
> > > If we are unable to find a suitable page when allocating the control
> > > page, do not invoke the OOM-killer: killing processes probably isn't
> > > going to help.
> > 
> > Originally kexec was made to reboot to test kernel quickly. If 1st
> > kernel is palyed and hurted in a bad state and developer want to discard
> > it and take a quick reboot, why don't we have a best try to make a
> > successful kexec load?
> 
> And if it kills off every process trying to get a suitable page,
> which then means you can't do anything other than power cycle,
> that's okay?

Yes, I agree on that it's non-sense if every process is killed. But will
each kexec load which need OOM-killer go that far? And there's only one
page (if 32 bit) or 2 pages (if 64 bit) for control page, it may not
need kill that many processes to pick one.

> 
> -- 
> RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
> FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
> according to speedtest.net.
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec
