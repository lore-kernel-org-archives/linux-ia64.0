From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 05 Jun 2004 03:48:56 +0000
Subject: Re: EFI-support for SMBIOS driver
Message-Id: <16577.17064.857172.598873@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <16577.6469.833064.763671@napali.hpl.hp.com>
	<20040605032902.GA7069@kroah.com>
In-Reply-To: <20040605032902.GA7069@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <greg@kroah.com>
Cc: davidm@hpl.hp.com, Michael_E_Brown@dell.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

>>>>> On Fri, 4 Jun 2004 20:29:02 -0700, Greg KH <greg@kroah.com> said:

  Greg> On Fri, Jun 04, 2004 at 05:52:21PM -0700, David Mosberger
  Greg> wrote:

  >> The patch below adds EFI support to the SMBIOS driver.

  Greg> The smbios driver is gone in 2.6.7-rc.  You don't need a
  Greg> driver for this, as you can do everything from userspace.

I know full well that it can be done in user-level --- via /dev/mem,
which lots of people dislike.  I certainly don't feel strongly about
it, but the SMBIOS driver made sense to me.

	--david
