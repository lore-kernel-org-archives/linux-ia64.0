From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 18 Dec 2002 18:18:16 +0000
Subject: Re: [Linux-ia64] RTC support on ia64
Message-Id: <marc-linux-ia64-105590709805610@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805600@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805600@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Joel,

On Wed, Dec 18, 2002 at 04:01:56PM +0100, Joel GUILLET wrote:
> 
> On Wed, 18 Dec 2002, Peter Chubb wrote:
> 
> > >>>>> "Alex" = Alex Williamson <alex_williamson@hp.com> writes:
> >
> > Alex> Joel, Does this provide more functionality than the EFI RTC?
> > Alex> Concerns I have w/ it on ia64 is that the rtc driver assumes you
> > Alex> have a legacy rtc at the legacy irq and port address.  This
> > Alex> won't work on HP zx1 boxes, the legacy hardware doesn't exist.
> > Alex> In the future, there's a possibility that the port address could
> > Alex> be allocated to non-legacy purposes.  Maybe ACPI could tell you
> > Alex> if you have a legacy RTC, it could at least tell you if you
> > Alex> support PC/AT compatible interrupts.  Thanks,
> >
> Peter> Yes it does.  There's no way to get a regular interrupt into user
> Peter> space from the EFI RTC.
> 
> The RTC legacy hardware seems to be on the i870 chipset. And if you don't
> have this one, you may not be able to use it.
> 
> Peter> I've been using the PMU to generate regular interrupts, and have a
> Peter> locally-modified amlat benchmark that does that.
> 
> Did you modify anything inside the kernel to make use of this timer ?
> With PMU, you mean "Performance Monitoring Unit" or "Power Management
> Utility" ? -- this question may look strange but with the acutal high
> resolution timer his ACPI PowerManagement timer, I've finally got some
> doubts.
> 

> I had a looked at the PMU code but I couldn't find anything about the way
> of using this timer ? Is it built-in somewhere ?
> Do I need to implement some code in the kernel to use it ? I've
> been trying to find some docs in the Web for quite a long time ... but
> without any results ! Does an user interface already exist ?
> 

PMU means Performance Monitoring Unit. What David meant is that you can get 
fine grain timer with the PMU by using the CPU_CYCLES event. You can program a 
PMU counter to overflow after a certain number of cycles have elapsed. It is 
very fine grain because you get down to the cycle. If you setup the counter to 
2^64-n, then it will overflow after n cycles. Setting this up is relatively 
easy.  I encourage you to download the libpfm library. It contains examples
on how to setup counters and get overflow notifications. You can get
the library and also the pfmon monitoring tool from:

		ftp://ftp.hpl.hp.com/pub/linux-ia64/libpfm-2.0.tar.gz
		ftp://ftp.hpl.hp.com/pub/linux-ia64/pfmon-2.0.tar.gz

These two package are beta versions of the upcoming 2.0 release.

-- 

-Stephane

